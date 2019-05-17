require 'spec_helper'
require 'openssl'
require 'gentle'
require 'gentle/message'

module Gentle
  describe "QueueRemote" do
    include Configuration

    before do
      Aws.config[:stub_responses] = true
      @client = Gentle::Client.new(load_configuration)
      @sqs_queues = [@client.to_quiet_queue, @client.from_quiet_queue]
      @default_wait_time = @sqs_queues.map(&:attributes).map { |attrs| attrs["ReceiveMessageWaitTimeSeconds"] }.max
      @sqs_queues.each { |queue| queue.set_attributes(attributes: { "ReceiveMessageWaitTimeSeconds": 1.to_s }) }

      @document = DocumentDouble.new(
        :message_id => '1234567',
        :date => Time.new(2013, 04, 05, 12, 30, 15).utc,
        :filename => 'neat_beans.xml',
        :client => @client,
        :type => 'Thinger'
      )

      @message = Message.new(:client => @client, :document => @document)
      @queue = Gentle::Queue.new(@client)
    end

    after do
      @sqs_queues.each do |queue|
        flush(queue)
      end
      @sqs_queues.each { |queue| queue.set_attributes(attributes: { "ReceiveMessageWaitTimeSeconds": @default_wait_time.to_s }) }
    end

    it "should be able to push a message onto the queue" do
      sent_message = @queue.send(@message)
      assert_instance_of Aws::SQS::Types::SendMessageResult, sent_message
    end

    it "should be able to fetch a message from the queue" do
      @client.from_quiet_queue.send_message(message_body: @message.to_xml)
      Aws::SQS::Queue.any_instance.expects(:receive_messages).once

      @queue.receive
    end

    private

    def flush(queue)
      pending_messages = queue.attributes["ApproximateNumberOfMessages"] || 0
      while pending_messages > 0
        queue.receive_message do |message|
          message.delete
          pending_messages -= 1
        end
      end
    end
  end
end
