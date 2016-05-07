class Database
  def initialize(name)
    @name = name
    @file = File.open("./#{name}.sdb", "w") # sebastiandb
  end

  def save(objs)
    # @file.write(serialize_objects(objs))
  end

  def load
    return [] # remove when fixed below
    # deserialize_objects(<contents of the file>)
  end

  private

  def serialize_objects(objs)
    # each object in here needs to be turned into a string
    # with all its state
    # A ruby object's only state is its instance variables.
    # You may have to resort to meta-programming here with
    # #instance_variable_get and #instance_variable_set
  end

  def deserialize_objects(objs)
    # each object here is turned from a string with all its
    # state into a Ruby object
  end
end
