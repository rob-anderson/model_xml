require 'test/unit'
require 'ostruct'
$:.unshift File.dirname(__FILE__) + "/../lib/"
require 'model_xml'

class TestStruct < OpenStruct
  include ModelXML
end

class ModelXMLTest < Test::Unit::TestCase

  def setup
    @t = TestStruct.new :foo => 1, :bar => 2
  end

  def test_class_simple
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml :foo
    end

    assert_equal [[:foo]], TestStruct.model_xml_generator.field_sets

    res = '<?xml version="1.0" encoding="UTF-8"?>
<teststruct>
  <foo>1</foo>
</teststruct>
'
    assert_equal res, @t.to_xml
  end

  def test_block_notation
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml do
        foo
        bar
      end
    end

    assert_equal [[:foo, :bar]], TestStruct.model_xml_generator.field_sets

    res = '<?xml version="1.0" encoding="UTF-8"?>
<teststruct>
  <foo>1</foo>
  <bar>2</bar>
</teststruct>
'
    assert_equal res, @t.to_xml
  end

  def test_inline_procs
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml do
        foo
        bar
        foobar Proc.new {|obj| obj.foo + obj.bar}
      end
    end

    res = '<?xml version="1.0" encoding="UTF-8"?>
<teststruct>
  <foo>1</foo>
  <bar>2</bar>
  <foobar>3</foobar>
</teststruct>
'
    assert_equal res, @t.to_xml
  end

  def test_skip_instruct
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml :foo, :bar
    end

    res = '<teststruct>
  <foo>1</foo>
  <bar>2</bar>
</teststruct>'
    assert_equal res, @t.to_xml(:skip_instruct => true)

  end
end
