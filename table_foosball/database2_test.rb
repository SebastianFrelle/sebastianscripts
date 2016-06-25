require_relative './database2'
require 'minitest/autorun'

class Database2Test < Minitest::Test
  class Foo
    def initialize(*args)
      i = 0
      args.each { |param| instance_variable_set("@var#{i+=1}", param) }
      # @timestamp = Time.now
    end

    def ==(other)
      self.instance_variables.each do |variable_name|
        self.instance_variable_get(variable_name) == other.instance_variable_get(variable_name)
      end
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
    name = :test_database
    test_database = Database.new(name)

    assert_equal Database, test_database.class
  end

  def test_save_string
    assert_equal "", File.read("./foo_test.sdb")

    @foodb.save("sebastian")

    assert_equal "String:sebastian", File.read("./foo_test.sdb")
  end

  def test_save_array
    @foodb.save(["sebastian"])

    assert_equal "---\n-\nString:sebastian", File.read("./foo_test.sdb")
  end

  def test_save_hash
    hash = {}
    
    hash[:key1] = "hej"
    hash[:key2] = "din"
    hash[:key3] = "skank"

    @foodb.save(hash)

    assert_equal File.read('hash_exp.txt'), File.read('foo_test.sdb')
  end

  def test_save_object_with_instance_variables
    @bardb.save(@bar1)

    assert_equal File.read("bar_exp.txt"), File.read("./bar_test.sdb")
  end

  def test_save_array_of_objects
    bars = [@bar1, @bar2]
    @bardb.save(bars)

    assert_equal File.read("array_of_objs_exp.txt"), File.read("bar_test.sdb")
  end

  def test_save_foo_with_bars_as_instance_variables
    @foodb.save(@foos)
    assert_equal File.read('foo_exp.txt'), File.read('foo_test.sdb')
  end
  
end