module ModelXML
  class BlockParser

    class << self

      def parse &block
        raise "block required" unless block_given?
        parser = self.new
        parser.instance_eval &block
        parser.field_set
      end

    end

    attr_reader :field_set

    def initialize
      @field_set = []
    end

    def method_missing *args

      # if the method is called without arguments, add it as a member of the field set
      if args.map(&:class) == [Symbol]
        @field_set << args[0]

      # otherwise add it as an array
      else
        @field_set << args
      end
    end

  end
end
