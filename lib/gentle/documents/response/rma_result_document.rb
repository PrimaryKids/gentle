module Gentle
  module Documents
    module Response
      class RMAResultDocument
        attr_reader :io

        def initialize(options = {})
          @io = options[:io]
          @document = Nokogiri::XML::Document.parse(@io)
        end

        def rma_result
          @rma_result ||= @document.css('RMAResult').first
        end

        def client_id
          @client_id ||= rma_result['ClientID']
        end

        def business_unit
          @business_unit ||= rma_result['BusinessUnit']
        end

        def receipt_date
          @receipt_date ||= Time.parse(rma_result['ReceiptDate']).utc
        end

        def rma_number
          @rma_number ||= rma_result['RMANumber']
        end

        def lines
          rma_result.children
            .select { |c| c.name == "Line" }
            .map { |l| Line.new(l) }
        end

        def lines_by_order_number
          lines.each_with_object({}) do |line, memo|
            next unless line.order_number

            memo[line.order_number] ||= []
            memo[line.order_number] << line
          end
        end

        def lines_by_rma_number
          { rma_number: lines }
        end

        private

        class Line < SimpleDelegator
          def item_number
            attributes["ItemNumber"].value
          end

          def quantity
            attributes["Quantity"].value
          end

          def product_status
            attributes["ProductStatus"].value
          end

          def order_number
            attribute = attributes["OrderNumber"]
            attribute ? attribute.value : nil
          end

          def notes
            attributes["Notes"].value
          end
        end
      end
    end
  end
end
