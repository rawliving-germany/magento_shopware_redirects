#!/usr/bin/env ruby

require 'minitest/autorun'

require_relative '../lib/memstore.rb'

class TestMemstore < MiniTest::Test
  class Obj
    attr_accessor :name
    def initialize(name:)
      @name = name
    end
  end

  def test_initialization
    memstore = Memstore.new Obj
    obj1 = Obj.new(name: 'Obj1')
    obj2 = Obj.new(name: 'Obj2')
  end

  def test_add_all_find_by
    memstore = Memstore.new Obj
    obj1 = Obj.new(name: 'Obj1')
    obj2 = Obj.new(name: 'Obj2')

    memstore.add_all [obj1, obj2]

    assert_equal obj1, memstore.find_with(name: 'Obj1')

    assert_equal obj1, memstore.find_by(attr: :name, value: 'Obj1')
    assert_equal obj2, memstore.find_by(attr: :name, value: 'Obj2')

    assert_equal obj2, memstore.find_or_create_by(attr: :name, value: 'Obj2')

    assert_equal 'Obj3', memstore.find_or_create_by(attr: :name, value: 'Obj3').name
  end
end
