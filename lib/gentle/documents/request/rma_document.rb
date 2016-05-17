require 'forwardable'
module Gentle
  module Documents
    module Request
      class RMADocument
        include Gentle::Documents::Document
        extend Forwardable

        NAMESPACE = "http://schemas.quietlogistics.com/V2/RMADocument.xsd"

        DATEFORMAT = "%Y%m%d_%H%M%S"

        class MissingOrderError < StandardError; end
        class MissingClientError < StandardError; end

        attr_reader :rma, :config, :name

        def initialize(options = {})
          @config          = options.fetch(:config).symbolize_keys
          @rma             = options.fetch(:rma)
          @order           = @rma.order
          @name            = "RMA_#{@rma.number}_#{date_stamp}.xml"
        end

        def to_xml
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.RMADocument('xmlns' => 'http://schemas.quietlogistics.com/V2/RMADocument.xsd') {


              xml.RMA('ClientID'       => @config[:client_id],
                      'BusinessUnit'   => @config[:business_unit],
                      'RMANumber'      => @rma.number,
                      'TrackingNumber' => @rma.tracking_number) {

                @rma.return_items.each do |returned_item|
                  xml.Line('LineNo'          => returned_item.inventory_unit.line_item_id,
                           'OrderNumber'     => @order.number,
                           'ItemNumber'      => returned_item.inventory_unit.variant.sku,
                           'Quantity'        => returned_item.inventory_unit.line_item.quantity,
                           'SaleUOM'         => 'EA', #Each
                           'ReturnReason'    => @rma.reason.name,
                           'CustomerComment' => '',
                           'Warehouse'       => warehouse
                  )
                end

              }

            }
          end
          builder.to_xml
        end

        def message
          "Sent RMA #{@number} to QL"
        end

        def date_stamp
          Time.now.strftime('%Y%m%d_%H%M%3N')
        end

        def business_unit
          @config[:business_unit]
        end

        def type
          'RMADocument'
        end

        def document_number
          @rma.number
        end

        def warehouse
          'Default'
        end

        def date
          @rma.created_at
        end

        def filename
          "#{business_unit}_#{type}_#{document_number}_#{date.strftime(DATEFORMAT)}.xml"
        end
      end
    end
  end
end
