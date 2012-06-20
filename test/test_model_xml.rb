require 'test/unit'
require 'ostruct'
$:.unshift File.dirname(__FILE__) + "/../lib/"
require 'model_xml'

class TestStruct < OpenStruct
  include ModelXML
end

class Parent < OpenStruct
  include ModelXML
  model_xml :foo, :child
end

class Child < OpenStruct
  include ModelXML
  model_xml :bar
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
<TestStruct>
  <foo>1</foo>
</TestStruct>
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
<TestStruct>
  <foo>1</foo>
  <bar>2</bar>
</TestStruct>
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
<TestStruct>
  <foo>1</foo>
  <bar>2</bar>
  <foobar>3</foobar>
</TestStruct>
'
    assert_equal res, @t.to_xml
  end

  def test_skip_instruct
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml :foo, :bar
    end

    res = '<TestStruct>
  <foo>1</foo>
  <bar>2</bar>
</TestStruct>
'
    assert_equal res, @t.to_xml(:skip_instruct => true)

  end

  def test_embedded_xml
    p = Parent.new(:foo => 1, :child => Child.new(:bar => 2))

    res = '<?xml version="1.0" encoding="UTF-8"?>
<Parent>
  <foo>1</foo>
  <Child>
    <bar>2</bar>
  </Child>
</Parent>
'
    assert_equal res, p.to_xml
  end

  def test_field_operator
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml do
        field :id, proc {|o| 'foo'}
      end
    end

    res = '<?xml version="1.0" encoding="UTF-8"?>
<TestStruct>
  <id>foo</id>
</TestStruct>
'
    assert_equal res, @t.to_xml
  end

  def test_except_and_include_options
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml :foo, :bar
    end

    res = '<?xml version="1.0" encoding="UTF-8"?>
<TestStruct>
  <foo>1</foo>
</TestStruct>
'
    assert_equal res, @t.to_xml(:except => [:bar])
    assert_equal res, @t.to_xml(:only => [:foo])

  end



end
