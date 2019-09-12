require 'spec_helper'
require 'gentle/blackboard'

module Gentle
  module Documents
    module Response
      class ThingerResponse
        attr_reader :contents
        def initialize(contents)
          @contents = contents
        end
      end
    end

    module Request
      class ThingerRequest
        attr_reader :contents
        def initialize(contents)
          @contents = contents
        end
      end
    end
  end
end

module Gentle
  describe "Blackboard" do
    before do
      Aws.config[:stub_responses] = true
      @bucket = mock()
      @bucket.stubs(:name).returns("Test Bucket")

      @client = mock()
      @client.stubs(:to_quiet_bucket).returns(@bucket)
      @client.stubs(:from_quiet_bucket).returns(@bucket)

      @document = mock()
      @document.stubs(:to_xml).returns("actually doesn't matter")
      @document.stubs(:filename).returns("abracadabra_1234_xyz.xml")

      @message = mock()
      @message.stubs(:document_type).returns('ShipmentOrderResult')
      @message.stubs(:document_name).returns('abracadabra_4321_zyx.xml')

      @blackboard = Blackboard.new(@client)
    end

    it "should be possible to post a document to the blackboard" do
      s3_object = mock()
      @bucket.expects(:object).returns(s3_object).once
      s3_object.expects(:put).once.with(body: @document.to_xml)
      @blackboard.post(@document)
    end

    it "should be possible to build a document for a response type" do
      Response.expects(:valid_type?).returns(true)
      response = @blackboard.build_document('ThingerResponse', 'thinger')
      assert_equal 'thinger', response.contents[:io]
    end

    it "should be possible to build a document for a request type" do
      Request.expects(:valid_type?).returns(true)
      response = @blackboard.build_document('ThingerRequest', 'thinger')
      assert_equal 'thinger', response.contents[:io]
    end

    it "should return nil if the type was not valid" do
      assert_nil @blackboard.build_document('ThingerRequest', 'thinger')
    end

    it "should be possible to fetch a document from the blackboard" do
      s3_object = mock()
      s3_object_output = Aws::S3::Types::GetObjectOutput.new(body: StringIO.new("fancy noodles"))
      s3_object.stubs(:get).returns(s3_object_output)
      @bucket.expects(:object).returns(s3_object)

      Response.expects(:valid_type?).returns(true)
      @message.stubs(:document_type).returns('ThingerResponse')
      assert_equal 'fancy noodles', @blackboard.fetch(@message).contents[:io]
    end

    it "should be possible to remove a document from the blackboard" do
      s3object = mock()
      s3object.expects(:delete)
      s3object.expects(:exists?).returns(true)

      @bucket.expects(:objects).returns({@message.document_name => s3object})
      assert_equal true, @blackboard.remove(@message)
    end

    it "should not raise an exception if the document for removal couldn't be found" do
      s3object = mock()
      s3object.expects(:delete).never
      s3object.expects(:exists?).returns(false)

      @bucket.expects(:objects).returns({@message.document_name => s3object})
      assert_equal false, @blackboard.remove(@message)
    end

    def assert_io(expectation, io)
      io.rewind
      assert_equal expectation, io.read
    end
  end
end
