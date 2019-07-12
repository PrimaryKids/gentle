require 'gentle/documents/response/shipment_order_result'
require 'gentle/documents/response/inventory_summary_ready'
require 'gentle/documents/response/inventory_event'

module Gentle
  module Response
    VALID_RESPONSE_TYPES = %w(ShipmentOrderResult InventorySummaryReady InventoryEvent
                              PurchaseOrderReceipt ShipmentOrderCancelResult)

    def self.valid_type?(type)
      VALID_RESPONSE_TYPES.include?(type)
    end
  end
end
