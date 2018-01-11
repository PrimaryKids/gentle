require 'spec_helper'
require 'gentle/response'

module Gentle
  describe Response do
    describe '.valid_type?' do
      it 'is valid with ShipmentOrderResult given' do
        assert Gentle::Response.valid_type?('ShipmentOrderResult')
      end

      it 'is valid with InventorySummaryReady given' do
        assert Gentle::Response.valid_type?('InventorySummaryReady')
      end

      it 'is invalid with anything else given' do
        refute Gentle::Response.valid_type?('AnythingElse')
      end
    end
  end
end
