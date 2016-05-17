require 'spec_helper'
require 'gentle/documents/request/shipment_order'

module Gentle
  module Documents
    module Request
      describe "RMADocument" do
        include Gentle::Documents::DocumentInterfaceTestcases

        before do
          @order  = OrderDouble.example
          @rma    = RMADouble.example
          @config = RMADouble::DEFAULT_OPTIONS[:config]

          @rma.order   = @order
          @object = @RMADocument = RMADocument.new(config: @config, rma: @rma)
        end

        it "should raise an error if an RMA wasn't passed in" do
          assert_raises KeyError do
            RMADocument.new(client: @client)
          end
        end

        it "should be able to generate an XML document" do
          document = Nokogiri::XML::Document.parse(@RMADocument.to_xml)

          expected_namespaces = {'xmlns' => 'http://schemas.quietlogistics.com/V2/RMADocument.xsd'}
          assert_equal expected_namespaces, document.collect_namespaces()

          assert_equal 1, document.css('RMA').length
          assert_equal @config[:client_id], document.css("RMA").attr('ClientID').value.to_i
          assert_equal @config[:business_unit], document.css("RMA").attr('BusinessUnit').value
          assert_equal @rma.number, document.css("RMA").attr('RMANumber').value
          assert_equal @rma.tracking_number, document.css("RMA").attr('TrackingNumber').value


          line_items = document.css('Line')
          assert_equal 1, line_items.length
          assert_line_item(@order.line_items.first, line_items.first)
        end


        private

        def assert_line_item(expected_line_item, line_item)
          assert_equal "1", line_item['LineNo']
          assert_equal  @order.number, line_item['OrderNumber']
          assert_equal expected_line_item.sku.to_s, line_item['ItemNumber']
          assert_equal expected_line_item.quantity.to_s, line_item['Quantity']
          assert_equal "EA", line_item['SaleUOM']
          assert_equal @rma.reason.name, line_item['ReturnReason']
          assert_equal "", line_item['CustomerComment']
        end

      end
    end
  end
end
