$:.unshift File.dirname __FILE__
require 'model_xml/generator'

module ModelXML

  def self.included base

    base.instance_eval do

      def model_xml *args, &block

        @model_xml_generator ||= ModelXML::Generator.new
        if block_given?
          @model_xml_generator.add_field_set(*args, &block)
        else
          @model_xml_generator.add_field_set *args
        end

      end

      # this is probably only ever required for testing
      def model_xml_reset!
        @model_xml_generator = ModelXML::Generator.new
      end

      def model_xml_generator
        @model_xml_generator
      end
    end

  end

  def to_xml options={}

    # if no generator is defined, pass straight through to the parent to_xml method, which may or may not exist
    if generator = self.class.model_xml_generator
      generator.generate_xml! self, options
    else
      super options
    end
  end

end

ActiveRecord::Base.send :include, ModelXML if defined?(ActiveRecord::Base)
