require 'test/unit'
require 'ostruct'
$:.unshift File.dirname(__FILE__) + "/../lib/"
require 'model_xml'

class TestStruct < OpenStruct
  include ModelXML
end

class Parent < OpenStruct
  include ModelXML
  model_xml :foo, :son
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

    assert_equal [[:foo]].to_set, TestStruct.model_xml_generator.field_sets

    res = '<?xml version="1.0" encoding="UTF-8"?>
<TestStruct>
  <foo>1</foo>
</TestStruct>
'
    assert_equal res, @t.to_xml
  end

  def test_class_simple_duplicates
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml :foo
      model_xml :foo
    end

    assert_equal [[:foo]].to_set, TestStruct.model_xml_generator.field_sets

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

    assert_equal [%i[foo bar].to_set].to_set, TestStruct.model_xml_generator.field_sets

    res = '<?xml version="1.0" encoding="UTF-8"?>
<TestStruct>
  <foo>1</foo>
  <bar>2</bar>
</TestStruct>
'
    assert_equal res, @t.to_xml
  end

  def test_block_notation_duplicates
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml do
        foo
        bar
      end
      model_xml do
        foo
        bar
      end
    end

    assert_equal [%i[foo bar].to_set].to_set, TestStruct.model_xml_generator.field_sets

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
        foobar proc { |obj| obj.foo + obj.bar }
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

  def test_inline_procs_duplicate
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml do
        foo
        bar
        foobar proc { |obj| obj.foo + obj.bar }
      end
      model_xml do
        foo
        bar
        foobar proc { |obj| obj.foo + obj.bar }
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
    assert_equal res, @t.to_xml(skip_instruct: true)
  end

  def test_skip_instruct_duplicate
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml :foo, :bar
      model_xml :foo, :bar
    end

    res = "<TestStruct>
  <foo>1</foo>
  <bar>2</bar>
</TestStruct>\n"
    assert_equal res, @t.to_xml(skip_instruct: true)
  end

  def test_embedded_xml
    p = Parent.new(:foo => 1, :son => Child.new(:bar => 2))

    res = '<?xml version="1.0" encoding="UTF-8"?>
<Parent>
  <foo>1</foo>
  <son>
    <bar>2</bar>
  </son>
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

  def test_field_operator_duplicates
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml do
        field :id, proc { |_o| 'foo' }
      end
      model_xml do
        field :id, proc { |_o| 'foo' }
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

  def test_except_and_include_options_duplicates
    TestStruct.instance_eval do
      model_xml_reset!
      model_xml :foo, :bar, :foo
      model_xml :foo, :bar, :foo
    end

    res = '<?xml version="1.0" encoding="UTF-8"?>
<TestStruct>
  <foo>1</foo>
</TestStruct>
'
    assert_equal res, @t.to_xml(except: [:bar])
    assert_equal res, @t.to_xml(only: [:foo])
  end
end
