module Gentle
  class Message

    NAMESPACE = "http://schemas.quietlogistics.com/V2/EventMessage.xsd"

    class MissingDocumentError < StandardError; end
    class MissingClientError < StandardError; end

    attr_reader :client, :document, :xml, :queue_message

    def initialize(options = {})
      @xml = options[:xml] ? Nokogiri::XML::Document.parse(options[:xml]) : nil
      @client = options[:client]
      @document = options[:document]
      @queue_message = options[:queue_message]
    end

    def delete
      @queue_message.delete if @queue_message
    end

    def to_xml
      return @xml.to_xml if @xml

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.EventMessage(attributes)
      end
      builder.to_xml
    end

    def document_type
      if @document
        @document.type
      elsif @xml
        @xml.css('EventMessage').first['DocumentType']
      end
    end

    def document_name
      if @document
        @document.filename
      elsif @xml
        @xml.css('EventMessage').first['DocumentName']
      end
    end

    def attributes
      raise(MissingClientError.new("client cannot be missing")) unless @client
      raise(MissingDocumentError.new("document cannot be missing")) unless @document
      {
        ClientId: @client.client_id, BusinessUnit: @client.business_unit,
        DocumentName: @document.filename, DocumentType: @document.type,
        Warehouse: @document.warehouse, MessageDate: @document.date.utc.iso8601,
        MessageId: @document.message_id, xmlns: NAMESPACE
      }
    end
  end
end
