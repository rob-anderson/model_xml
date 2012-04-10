require 'rubygems'
require 'builder'
require 'nokogiri'
require 'model_xml/block_parser'

module ModelXML
  class Generator

    attr_reader :field_sets

    def initialize
      @field_sets ||= []
    end

    # three types of argument list are expected:
    #
    # 1. an unnamed fieldset expressed as any number of symbols eg
    # model_xml :id, :first_name, :last_name, [:embossed_name, :getter => proc {|u| "#{u.first_name} #{u.last_name}".upcase}]
    #
    # 2. a named fieldset in block notation eg
    # model_xml :personal_data do
    #   :first_name
    #   :last_name
    #   :embossed_name proc {|u| "#{u.first_name} #{u.last_name}".upcase}
    # end
    #
    # 3. an unnamed fieldset in block notation eg
    # model_xml do
    #   :first_name
    #   last_name
    # end

    def add_field_set *args, &block

      # if the argument list is empty and we have a block, it is an unnamed block
      if args.empty? && block_given?
        @field_sets << ModelXML::BlockParser.parse(&block)

      # otherwise if the argument list is a symbol and we have a block, it is a named block
      elsif args.map(&:class) == [Symbol] && block_given?
        name = args[0]
        @field_sets << {name => ModelXML::BlockParser.parse(&block)}

      # otherwise assume it is a simple fieldset expressed as symbols
      else
        @field_sets << args
      end
    end

    # apply any options to the default field sets to generate a single array of fields
    def generate_field_list options={}

      field_list = []
      @field_sets.each do |field_set|

        # if the field set is a hash then it is a hash of conditional field sets
        # which should only be included if the conditions are present as options
        if field_set.is_a?(Hash)
          field_set.each do |k, v|
            field_list += v if options[k]
          end

        # otherwise, always include
        else
          field_list += field_set
        end
      end
      field_list
    end

    def generate_xml! object, options={}

      field_list = generate_field_list(options)

      xml = Builder::XmlMarkup.new
      unless options[:skip_instruct]
        xml.instruct!
      end

      xml.tag! object.class.to_s.downcase do

        field_list.each do |field|

          # if the field is a symbol, treat it as the field name and the getter method
          if field.is_a?(Symbol)
            tag = field
            content = object.send(field)

          # if the field is an array of a symbol followed by a proc, assume the symbol is the field name and the proc is the getter
          elsif field.is_a?(Array) && field.map(&:class) == [Symbol, Proc]
            tag = field[0]
            content = field[1].call(object)

          # otherwise we have garbage
          else
           raise "ModelXML unable to parse #{field.inspect}"
          end

          # if the content implements a to_xml method which returns a non-nil value, insert as raw xml
          if content.respond_to?(:to_xml) && inline_content = content.to_xml(:skip_instruct => true, :skip_types => true)
            xml << inline_content

          # otherwise create the tag normally
          else
            xml.tag! tag, content
          end
        end
      end

      # builder will screw up the indentation of embedded xml objects, so use nokogiri to format it nicely
      output = xml.target!.gsub("\n","").gsub("  ","")
      Nokogiri.parse(output).to_s

    end
  end
end