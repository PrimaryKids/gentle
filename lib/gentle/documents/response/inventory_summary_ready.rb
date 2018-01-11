module Gentle
  module Documents
    module Response
      class InventorySummaryReady
        attr_reader :io

        def initialize(options = {})
          @io = options[:io]
          @document = Nokogiri::XML::Document.parse(@io)
        end

        def warehouse
          @document.root.attributes['Warehouse'].value
        end

        def inventories
          @document.root
            .children
            .select { |c| c.name == 'Inventory' }
            .map { |i| Inventory.new(i) }
        end

        private

        class Inventory < SimpleDelegator
          def item_number
            attributes['ItemNumber'].value
          end

          def quantity_available
            children
              .select { |c| c.name == 'ItemStatus' && c.attributes['Status'].value == 'Avail' }
              .first
              .attributes['Quantity'].value
          end
        end
      end
    end
  end
end
