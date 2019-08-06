require 'forwardable'
require 'gentle/documents/request/hash_converter'
require 'gentle/phase_1_set'

module Gentle
  module Documents
    module Request
      class ShipmentOrder
        include Gentle::Documents::Document
        include Gentle::Documents::Request::HashConverter
        extend Forwardable

        NAMESPACE = "http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd"

        DATEFORMAT = "%Y%m%d_%H%M%S"

        class MissingOrderError < StandardError; end
        class MissingClientError < StandardError; end

        attr_reader :shipment, :client

        def_delegators :@client, :warehouse, :business_unit, :client_id

        def initialize(options = {})
          @client   = options.fetch(:client)
          @shipment = options.fetch(:shipment)
          @comments = options.fetch(:comments, nil) || @shipment.order.special_instructions
          @notes = options.fetch(:notes)
          @item_filter = options.fetch(:item_filter, nil) || Proc.new { |line_item| true }
          @shipment_number = @shipment.number
        end

        def to_xml
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.ShipOrderDocument('xmlns' => 'http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd') {

              xml.ClientID client_id
              xml.BusinessUnit business_unit

              xml.OrderHeader('OrderNumber' => @shipment_number,
                              'OrderType'   => order_type,
                              'OrderDate'   => date.utc.iso8601) {

                xml.Extension @shipment.order.number

                xml.Comments @comments

                xml.ShipMode('Carrier'      => @shipment.shipping_method.carrier,
                             'ServiceLevel' => @shipment.shipping_method.service_level)

                xml.ShipTo(ship_to_hash)
                xml.BillTo(bill_to_hash)

                @notes.each do |note|
                  xml.Notes('NoteType': note[:note_type],
                            'NoteValue': note[:note_value])
                end

                if @shipment.respond_to?(:value_added_services)
                  @shipment.value_added_services.each do |service|
                    xml.ValueAddedService('Service'     => service[:service],
                                          'ServiceType' => service[:service_type])
                  end
                end
              }

              add_items_to_shipment_order(order_items, xml)
            }
          end
          builder.to_xml
        end

        def add_items_to_shipment_order(items, xml)
          item_hashes = convert_to_hashes(items)
          grouped_items = group_items_by_sku(item_hashes)
          grouped_items.each_with_index do |hash, index|
            hash['Line'] = index + 1
            xml.OrderDetails(hash)
          end
        end

        def convert_to_hashes(items)
          items.map do |item|
            if Phase1Set.match(item)
              add_individual_phase_1_items(item)
            elsif contain_parts? item
              add_item_parts(item.part_line_items)
            else
              line_item_hash(item)
            end
          end.flatten
        end

        def group_items_by_sku(item_hashes)
          grouped = item_hashes.group_by {|hash| hash['ItemNumber'] }
          grouped.values.map do |hashes|
            hash = hashes.first
            update_quantity(hash, total_quantity(hashes))
          end
        end

        def contain_parts?(item)
          item.respond_to?(:part_line_items) && !item.part_line_items.empty?
        end

        def add_item_parts(part_line_items)
          part_line_items.map { |part| part_line_item_hash(part) }
        end

        def add_individual_phase_1_items(phase_1_item)
          phase_1 = Phase1Set.new(phase_1_item).included_items
          phase_1.map { |item| line_item_hash(item) }
        end

        def update_quantity(hash, quantity)
          hash['QuantityOrdered'] = hash['QuantityToShip'] = quantity
          hash
        end

        def total_quantity(hashes)
          hashes.map{ |hash| hash['QuantityOrdered'] }.reduce(:+)
        end

        def order_items
          @shipment.line_items.select(&@item_filter)
        end

        def order_type
          'SO'
        end

        def ship_address
          @shipment.order.ship_address
        end

        def bill_address
          @shipment.order.bill_address
        end

        def full_name
          ship_address.full_name
        end

        def message
          "Succesfully Sent Shipment #{@shipment_number} to Quiet Logistics"
        end

        def date_stamp
          Time.now.strftime('%Y%m%d_%H%M%3N')
        end

        def type
          'ShipmentOrder'
        end

        def document_number
          @shipment_number
        end

        def date
          @shipment.order.completed_at
        end

        def filename
          "#{business_unit}_#{type}_#{document_number}_#{date.strftime(DATEFORMAT)}.xml"
        end

        def message_id
          SecureRandom.uuid
        end
      end
    end
  end
end
