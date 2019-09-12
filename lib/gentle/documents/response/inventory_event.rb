module Gentle
  module Documents
    module Response
      class InventoryEvent
        attr_reader :io

        def initialize(options = {})
          @io = options[:io]
          @document = Nokogiri::XML::Document.parse(@io)
        end

        def inventory_event_message
          @inventory_event_message ||= @document.css('InventoryEventMessage')
        end

        def client_id
          @client_id ||= inventory_event_message['ClientID']
        end

        def business_unit
          @business_unit ||= inventory_event_message['BusinessUnit']
        end

        def event_type
          @event_type ||= inventory_event_message['EventType']
        end

        def item_number
          @item_number ||= inventory_event_message['ItemNumber']
        end

        def delta_quantity
          @delta_quantity ||= inventory_event_message['DeltaQuantity']
        end

        def from_status
          @from_status ||= inventory_event_message['FromStatus']
        end

        def to_status
          @to_status ||= inventory_event_message['ToStatus']
        end

        def reason_code
          @reason_code ||= inventory_event_message["ReasonCode"]
        end
      end
    end
  end
end
