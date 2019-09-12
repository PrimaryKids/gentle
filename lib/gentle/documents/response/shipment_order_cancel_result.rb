module Gentle
  module Documents
    module Response
      class ShipmentOrderCancelResult
        attr_reader :io

        def initialize(options = {})
          @io = options[:io]
          @document = Nokogiri::XML::Document.parse(@io)
        end

        def so_cancel_result
          @so_cancel_result ||= @document.css('SOCancelResult')
        end

        def client_id
          @client_id ||= so_cancel_result['ClientID']
        end

        def business_unit
          @business_unit ||= so_cancel_result['BusinessUnit']
        end

        def item_number
          @item_number ||= so_cancel_result['ItemNumber']
        end

        def quantity_ordered
          @quantity_ordered ||= so_cancel_result['QuantityOrdered']
        end

        def quantity_available
          @from_status ||= so_cancel_result['QuantityAvailable']
        end

        def reason
          @reason ||= so_cancel_result['Reason']
        end
      end
    end
  end
end
