require 'gentle/documents/response/inventory_event'
require 'gentle/documents/response/inventory_summary_ready'
require 'gentle/documents/response/rma_result_document'
require 'gentle/documents/response/shipment_order_cancel_result'
require 'gentle/documents/response/shipment_order_result'

module Gentle
  module Response
    VALID_RESPONSE_TYPES = %w(ShipmentOrderResult InventorySummaryReady InventoryEvent
                              PurchaseOrderReceipt ShipmentOrderCancelResult, RmaResultDocument)

    def self.valid_type?(type)
      VALID_RESPONSE_TYPES.include?(type)
    end
  end
end
