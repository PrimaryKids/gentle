require 'aws-sdk-s3'
require 'aws-sdk-sqs'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/hash/indifferent_access'

module Gentle
  class Client

    class InitializationError < StandardError; end
    class InvalidBucketError < StandardError; end
    class InvalidQueueError < StandardError; end

    attr_reader :client_id, :business_unit, :warehouse

    def initialize(options = {})
      options        = options.with_indifferent_access
      @buckets       = options[:buckets]
      @queues        = options[:queues]
      @client_id     = options[:client_id]
      @warehouse     = options[:warehouse]
      @business_unit = options[:business_unit]
      @credentials   = options.slice(:access_key_id, :secret_access_key)
      verify!
    end

    def to_quiet_bucket
      @to_quiet_bucket ||= fetch_bucket(@buckets[:to])
    end

    def from_quiet_bucket
      @from_quiet_bucket ||= fetch_bucket(@buckets[:from])
    end

    def to_quiet_queue
      @to_quiet_queue ||= fetch_queue(@queues[:to])
    end

    def from_quiet_queue
      @from_quiet_queue ||= fetch_queue(@queues[:from])
    end

    def quiet_inventory_queue
      @quiet_inventory_queue ||= fetch_queue(@queues[:inventory])
    end

    private
    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new(credentials: Aws::Credentials.new(*@credentials.values))
    end

    def s3_client
      @s3_client ||= Aws::S3::Client.new(credentials: Aws::Credentials.new(*@credentials.values))
    end

    def fetch_bucket(name)
      raise(InvalidBucketError.new("#{name} is not a valid bucket")) unless bucket_exists?(name)

      Aws::S3::Bucket.new(name, client: s3_client)
    end

    def fetch_queue(url)
      raise(InvalidQueueError.new("#{url} is not a valid queue")) unless queue_exists?(url)

      Aws::SQS::Queue.new(url, client: sqs_client)
    end

    def verify!
      raise(InitializationError.new("Credentials cannot be missing")) unless all_credentials?
      raise(InitializationError.new("Both to and from buckets need to be set")) unless all_buckets?
      raise(InitializationError.new("To, From and Inventory queues need to be set")) unless all_queues?
      raise(InitializationError.new("client_id needs to be set")) unless @client_id
      raise(InitializationError.new("business_unit needs to be set")) unless @business_unit
      raise(InitializationError.new("warehouse needs to be set")) unless @warehouse
    end

    def all_credentials?
      has_keys?(@credentials, [:access_key_id, :secret_access_key])
    end

    def all_buckets?
      has_keys?(@buckets, [:from, :to])
    end

    def all_queues?
      has_keys?(@queues, [:from, :to, :inventory])
    end

    def bucket_exists?(bucket_name)
      begin
        s3_client.get_bucket_versioning(bucket: bucket_name)
        true
      rescue
        false
      end
    end

    def queue_exists?(queue_url)
      sqs_client.get_queue_attributes(queue_url: queue_url, attribute_names: ["QueueArn"])
    rescue
      false
    else
      true
    end

    def has_keys?(hash, keys)
      keys.reduce(hash) {|result, key| result && hash[key]}
    end
  end
end
