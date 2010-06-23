require 'test/unit'

require 'rubygems'

require 'flexmock'
require 'flexmock/test_unit'

module ActiveRecord
  module Acts
    module Tree
    end
  end
end

require File.dirname(__FILE__) + '/../lib/acts_as_tree_extensions.rb'

class FakeRecord
  
  include ActiveRecord::Acts::Tree::InstanceMethods
  extend ActiveRecord::Acts::Tree::ClassMethods
  
  attr_reader :id, :parent_id
  
  def initialize(attribs)
    attribs.each { |k,v| instance_variable_set("@#{k}", v) }
  end
  
  def primary_key
    @id
  end
  
  def self.find(what, options = {})
    [ new(:id => 1, :parent_id => nil),
      new(:id => 2, :parent_id => nil),
      new(:id => 3, :parent_id => 1),
      new(:id => 4, :parent_id => 3),
      new(:id => 5, :parent_id => 2),
      new(:id => 6, :parent_id => 4),
      new(:id => 7, :parent_id => 2)
    ]
  end
  
  def ==(other)
    other.primary_key == primary_key
  end
  
end

class Fixnum
  def primary_key
    self
  end
end

class ActsAsTreeExtensionsTest < Test::Unit::TestCase
  
  def test_order_should_be_passed_to_finder
    flexmock(FakeRecord).should_receive(:find).once.with(:all, { :order => 'foobar ASC' }).and_return([])
    FakeRecord.child_map('foobar ASC')
  end
  
  def test_child_map_is_correct
    map = FakeRecord.child_map
    assert_equal map[nil], [1,2]
    assert_equal map[1], [3]
    assert_equal map[2], [5,7]
    assert_equal map[3], [4]
    assert_equal map[4], [6]
    assert_equal map[5], nil
    assert_equal map[6], nil
  end
  
  def test_indent_is_correct
    assert_equal FakeRecord.indent, [
      [0, 1],
        [1, 3],
          [2, 4],
            [3, 6],
      [0, 2],
        [1, 5],
        [1, 7]
    ]
  end
  
  def test_root_returns_true_when_parent_id_is_nil
    f = FakeRecord.new(:parent_id => nil)
    assert f.root?
  end
  
  def test_root_returns_false_when_parent_id_is_not_nil
    f = FakeRecord.new(:parent_id => 1)
    assert !f.root?
  end
  
end