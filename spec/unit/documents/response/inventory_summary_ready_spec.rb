require 'spec_helper'
require 'gentle/documents/response/inventory_summary_ready'

module Gentle
  module Documents
    module Response
      describe "InventorySummaryReady" do
        include Fixtures

        it "has warehouse name" do
          document = load_response('inventory_summary')
          order_result = InventorySummaryReady.new(io: document)

          assert_equal 'DVN', order_result.warehouse
        end

        describe '#inventories' do
          it "returns available inventory levels" do
            document = load_response('inventory_summary')
            order_result = InventorySummaryReady.new(io: document)

            assert_equal Array, order_result.inventories.class
            assert_equal ["5", "2"], order_result.inventories.collect(&:quantity_available)
          end
        end
      end
    end
  end
end
