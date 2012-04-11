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

  def test_parse_with_id_field
    block = Proc.new do
      field :id, 2
    end
    assert_equal [[:id, 2]], ModelXML::BlockParser.parse(&block).inspect
  end

end

