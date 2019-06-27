module Gentle
  module Documents
    module Response
      class PurchaseOrderReceipt
        attr_reader :io

        def initialize(options = {})
          @io = options[:io]
          @document = Nokogiri::XML::Document.parse(@io)
        end

        def namespace
          @namespace ||= @document.collect_namespaces['xmlns']
        end

        def po_lines
          @document.root
            .children
            .find { |c| c.name == 'POReceipt' }
            .children
            .select { |c| c.name == 'PoLine' }
            .map { |l| POLine.new(l) }
        end

        private

        class POLine < SimpleDelegator
          def item_number
            attributes['ItemNumber'].value
          end

          def quantity_available
            attributes['ReceiveQuantity'].value
          end

          def warehouse
            attributes['Warehouse'].value
          end

          def status
            attributes['Status'].value
          end
        end
      end
    end
  end
end
