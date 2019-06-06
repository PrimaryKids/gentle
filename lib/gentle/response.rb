require 'gentle/documents/response/shipment_order_result'
require 'gentle/documents/response/inventory_summary_ready'

module Gentle
  module Response
    VALID_RESPONSE_TYPES = %w(ShipmentOrderResult InventorySummaryReady InventoryEvent)

    def self.valid_type?(type)
      VALID_RESPONSE_TYPES.include?(type)
    end
  end
end
