module Gentle
  class Queue
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def send(message)
      queue = client.to_quiet_queue
      queue.send_message(message_body: message.to_xml)
    end

    def receive
      receive_from(client.from_quiet_queue)
    end

    def receive_inventory
      receive_from(client.quiet_inventory_queue)
    end

    def approximate_pending_messages
      client.from_quiet_queue.approximate_number_of_messages
    end

    private

    def receive_from(queue)
      msg = queue.receive_messages(max_number_of_messages: 1).first

      if msg.nil?
        false
      else
        build_message(msg) || Message.new
      end
    end

    def build_message(msg)
      if received_error? msg
        ErrorMessage.new(xml: msg.body, queue_message: msg)
      else
        Message.new(xml: msg.body, queue_message: msg)
      end
    end

    def received_error?(msg)
      msg.body.include? "<ErrorMessage"
    end
  end
end
