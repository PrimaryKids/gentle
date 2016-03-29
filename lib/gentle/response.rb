require 'gentle/documents/response/shipment_order_result'

module Gentle
  module Response
    VALID_RESPONSE_TYPES = %w(ShipmentOrderResult)

    def self.valid_type?(type)
      VALID_RESPONSE_TYPES.include?(type)
    end
  end
end
