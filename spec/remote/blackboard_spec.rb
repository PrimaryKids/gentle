require 'spec_helper'
require 'gentle'
require 'gentle/blackboard'

module Gentle
  describe "BlackboardRemote" do
    include Configuration
    include Fixtures

    before do
      Aws.config[:stub_responses] = true
      @client = Client.new(load_configuration)
      @blackboard = Blackboard.new(@client)
      @document = DocumentDouble.new(
        message_id: '1234567',
        date: Time.new(2013, 04, 05, 12, 30, 15).utc,
        filename: 'neat_beans.xml',
        client: @client,
        type: 'ShipmentOrderResult'
      )
    end

    after do
      buckets = [@client.to_quiet_bucket, @client.from_quiet_bucket]
      buckets.each { |bucket| bucket.objects.map(&:delete) }
    end

    it "should be able to write a document to an S3 bucket" do
      Aws::S3::Object.any_instance.expects(:put).once.with(body: @document.to_xml)
      @blackboard.post(@document)
    end

    it "should be able to fetch a document from an S3 bucket when given a message" do
      expected_contents = load_response('shipment_order_result')
      @client.from_quiet_bucket.object(@document.filename).put(body: expected_contents)
      message = MessageDouble.new(document_name: @document.filename, document_type: @document.type)

      s3_object = mock()
      s3_object_output = Aws::S3::Types::GetObjectOutput.new(body: StringIO.new(expected_contents))
      s3_object.stubs(:get).returns(s3_object_output)
      Aws::S3::Bucket.any_instance.expects(:object).once.with(message.document_name).returns(s3_object)

      @blackboard.fetch(message)
    end
  end
end
