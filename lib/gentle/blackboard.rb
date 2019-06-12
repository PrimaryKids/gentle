require 'gentle/response'
require 'gentle/request'
module Gentle
  class Blackboard
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def post(document)
      bucket = client.to_quiet_bucket
      if bucket.object(document.filename).put(body: document.to_xml)
        Message.new(:client => @client, :document => document)
      end
    end

    def fetch(message)
      bucket = client.from_quiet_bucket
      contents = bucket.object(message.document_name).get.body.read
      build_document(message.document_type, contents)
    end

    def remove(message)
      bucket = client.from_quiet_bucket
      object = bucket.object(message.document_name)
      if object.exists?
        object.delete
        true
      else
        false
      end
    end

    def build_document(type, contents)
      namespace = if Response.valid_type?(type)
        Documents::Response
      elsif Request.valid_type?(type)
        Documents::Request
      end
      namespace.const_get(type).new(:io => contents) if namespace
    end
  end
end
