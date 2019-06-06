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
      queue = client.from_quiet_queue
      msg = queue.receive_messages(max_number_of_messages: 1).first
      build_message(msg) || Message.new
    end

    def receive_inventory
      queue = client.quiet_inventory_bucket
      msg = queue.receive_messages(max_number_of_messages: 1).first
      build_message(msg) || Message.new
    end

    def approximate_pending_messages
      client.from_quiet_queue.approximate_number_of_messages
    end

    private

    def build_message(msg)
      if received_error? msg
        ErrorMessage.new(xml: msg.body)
      else
        Message.new(xml: msg.body)
      end
    end

    def received_error?(msg)
      msg.body.include? "<ErrorMessage"
    end
  end
end
