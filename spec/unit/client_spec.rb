require 'spec_helper'
require 'gentle/client'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/keys'

module Gentle
  describe "Client" do
    before do
      Aws.config[:stub_responses] = true
      @options = {
        access_key_id: 'abracadabra',
        secret_access_key: 'alakazam',
        client_id: 'Gentle',
        business_unit: 'Gentle',
        warehouse: 'SPACE',
        buckets: {
          to: 'gentle-to-quiet',
          from: 'gentle-from-quiet'
        },
        queues: {
          to: 'http://queue.amazonaws.com/123456789/gentle_to_quiet',
          from: 'http://queue.amazonaws.com/123456789/gentle_from_quiet',
          inventory: 'http://queue.amazonaws.com/123456789/gentle_inventory'
        }
      }
      @client = Gentle::Client.new(@options)
    end

    after do
      Aws.config[:stub_responses] = false
    end

    it "should be able to handle configuration that is passed in with keys as strings" do
      client = Gentle::Client.new(@options.stringify_keys)
      assert_equal 'Gentle', client.client_id
      assert_equal 'Gentle', client.business_unit
    end

    it "should not be possible to initialize a client without credentials" do
      assert_raises Gentle::Client::InitializationError do
        Gentle::Client.new(@options.except(:access_key_id, :secret_access_key))
      end
    end

    it "should not be possible to initialize a client without a client_id" do
      assert_raises Gentle::Client::InitializationError do
        Gentle::Client.new(@options.except(:client_id))
      end
    end

    it "should not be possible to initialize a client with a business_unit" do
      assert_raises Gentle::Client::InitializationError do
        Gentle::Client.new(@options.except(:business_unit))
      end
    end

    it "should not be possible to initialize a client with missing bucket information" do
      assert_raises Gentle::Client::InitializationError do
        Gentle::Client.new(@options.except(:buckets))
      end
    end

    it "should not be possible to initialize a client with partial bucket information" do
      assert_raises Gentle::Client::InitializationError do
        buckets = {to: 'neato'}
        Gentle::Client.new(@options.merge(buckets: buckets))
      end
    end

    it "should not be possible to initialize a client with missing queue information" do
      assert_raises Gentle::Client::InitializationError do
        Gentle::Client.new(@options.except(:queues))
      end
    end

    it "should not be possible to initialize a client with partial queue information" do
      assert_raises Gentle::Client::InitializationError do
        queues = {inventory: 'neato'}
        Gentle::Client.new(@options.merge(queues: queues))
      end
    end

    it "should raise an error if the bucket names are invalid" do
      Aws::S3::Client.any_instance.expects(:get_bucket_versioning).at_least_once.raises(StandardError)
      assert_raises Gentle::Client::InvalidBucketError do
        @client.to_quiet_bucket
      end
    end

    it "should raise an error if the queue names are invalid" do
      Aws::SQS::Client.any_instance.expects(:get_queue_attributes).at_least_once.raises(StandardError)
      assert_raises Gentle::Client::InvalidQueueError do
        @client.to_quiet_queue
      end
    end
  end
end
