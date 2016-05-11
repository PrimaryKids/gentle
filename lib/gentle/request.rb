require 'gentle/documents/request/shipment_order'
require 'gentle/documents/request/rma'

module Gentle
  module Request
    VALID_REQUEST_TYPES = %w(ShipmentOrder, RMADocument)

    def self.valid_type?(type)
      VALID_REQUEST_TYPES.include?(type)
    end
  end
end
