require_relative './database'
require 'minitest/autorun'

class DatabaseTest < Minitest::Test
  class Foo
    def initialize(*args)
      i = 0
      args.each { |param| instance_variable_set("@var#{i+=1}", param) }
      @timestamp = Time.now
    end
  end

  class Bar
    def initialize(*args)
      i = 0
      args.each { |param| instance_variable_set("@var#{i+=1}", param) }
      @timestamp = Time.now
    end
  end

  def setup
    File.open("./foo_test.sdb", "w") {}
    File.open("./bar_test.sdb", "w") {}

    @foodb = Database.new(:foo_test)
    @bardb = Database.new(:bar_test)

    @bar1 = Bar.new("name1")
    @bar2 = Bar.new("name2")
    @bar3 = Bar.new("name3")
    @bar4 = Bar.new("name4")

    @foo1 = Foo.new([@bar1, @bar2, @bar3], [@bar4], 10, 0)
    @foo2 = Foo.new([@bar2], [@bar3], 6, 10)
    @foo3 = Foo.new([@bar1, @bar2], [@bar3, @bar4], 10, 5)
    @foo4 = Foo.new([@bar1], [@bar3, @bar4], 10, 9)

    @bars = [@bar1, @bar2, @bar3, @bar4]
    @foos = [@foo1, @foo2, @foo3, @foo4]
  end

  def teardown
    File.delete("./foo_test.sdb", "./bar_test.sdb")
  end

  def test_create_new_database
    name = :test_database
    test_database = Database.new(name)

    assert_equal Database, test_database.class
  end

  def test_save_and_load_foos_on_database
    assert_equal "", File.read("./foo_test.sdb")
    assert_nil @foodb.load

    @foodb.save(@foos)

    refute_equal "", File.read("./foo_test.sdb")
    compare_object_states @foos, @foodb.load
  end

  def test_save_and_load_bars_on_database
    assert_equal "", File.read("./bar_test.sdb")
    assert_nil @bardb.load

    @bardb.save(@bars)

    refute_equal "", File.read("./bar_test.sdb")
    
    compare_object_states @bars, @bardb.load
  end

  private

  def compare_object_states exp, act
    exp.zip(act).each do |exp_obj, act_obj|
      assert_equal exp_obj.class, act_obj.class

      exp_obj.instance_variables.each do |variable_name|
        exp_value = exp_obj.instance_variable_get(variable_name)
        act_value = act_obj.instance_variable_get(variable_name)

        if exp_value.kind_of? Array
          compare_object_states exp_value, act_value
        elsif exp_value.instance_variables.empty?
          assert_equal exp_value.to_s, act_value.to_s
        end
      end
    end
  end
end