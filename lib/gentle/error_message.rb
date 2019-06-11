module Gentle
  class ErrorMessage
    attr_reader :xml, :queue_message

    def initialize(options = {})
      @xml = Nokogiri::XML::Document.parse(options[:xml]) if options[:xml]
      @queue_message = options[:queue_message]
    end

    def to_xml
      @xml.serialize(encoding: "UTF-8")
    end

    def identifier
      filename[2]
    end
    alias_method :shipment_number, :identifier

    def object_type
      filename[1] unless filename.nil?
    end

    def result_description
      @result_description ||= @xml.css("ErrorMessage").first["ResultDescription"]
    end
    def filename
      @filename ||= result_description.split('_') unless result_description.nil?
    end
  end
end
