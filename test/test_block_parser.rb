require 'test/unit'
$:.unshift File.dirname(__FILE__) + "/../lib/"
require 'model_xml/block_parser'

class BlockParserTest < Test::Unit::TestCase

  def test_simple_parse
    block = Proc.new do
      foo
      bar 3, 4
    end
    assert_equal [:foo, [:bar, 3, 4]], ModelXML::BlockParser.parse(&block)
  end

end

