require_relative './database'
require 'minitest/autorun'

class DatabaseTest < Minitest::Test
  class Foo
    def initialize(*args)
      i = 0
      args.each { |param| instance_variable_set("@var#{i+=1}", param) }
      @timestamp = Time.now
    end

    def ==(other)
      instance_variables.each do |variable_name|
        return false unless instance_variable_get(variable_name) == other.instance_variable_get(variable_name)
      end

      true
    end

    alias eql? ==

    def hash
      instance_variables.map { |name| [name, instance_variable_get(name)] }.hash
    end
  end

  class Bar < Foo; end

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
    name = :test_db
    test_db = Database.new(name)

    assert_equal Database, test_db.class
  end

  def test_save_load_string
    @foodb.save("sebastian")

    assert_equal "sebastian", @foodb.load
  end

  def test_save_load_time
    
  end

  def test_save_load_array
    arr = ["sebastian"]

    @foodb.save(arr)

    assert_equal arr, @foodb.load
  end

  def test_save_load_hash
    hash = {}
    
    hash[:key1] = "foo"
    hash[:key2] = "bar"
    hash[:key3] = "foobar"
    hash[:key4] = { :foz => :baz }
    hash[:key6] = ["hey", "you", "there"]
    hash[:key7] = { ["element1", :element2, { @bar1 => :element3 } ] => { Time.now => { @foo1 => 2 } } }

    @foodb.save(hash)

    assert_equal hash, @foodb.load
  end

  def test_save_object_with_instance_variables
    @bardb.save(@bar1)

    assert_equal @bar1, @bardb.load
  end

  def test_save_array_of_simple_objects
    objs = ["hey", "ho", ["let's", "go"], 2]
    
    @foodb.save(objs)
    
    assert_equal objs, @foodb.load
  end

  def test_save_array_of_objects
    bars = [@bar1, @bar2]

    @bardb.save(bars)

    assert_equal bars, @bardb.load
  end

  def test_save_foo_with_bars_as_instance_variables
    @foodb.save(@foos)

    assert_equal @foos, @foodb.load
  end

  def test_save_load_nil
    @foodb.save(nil)

    assert_equal nil, @foodb.load
  end

  def test_save_empty_array
    @foodb.save([])

    assert_equal [], @foodb.load
  end

  def test_save_empty_hash
    @foodb.save({})

    assert_equal({}, @foodb.load)
  end
end