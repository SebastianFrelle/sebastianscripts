class Database
  def initialize(name)
    @name = name
    @file = File.open("./#{name}.sdb", "w+") # sebastiandb
  end

  def save(objs)
    @file.rewind
    @file.write(serialize_objects(objs))
  end

  def load
    return []
    # @file.rewind
    # deserialize_objects(@file.read)
  end

  private

  def serialize_objects(objs)
    # each object in here needs to be turned into a string
    # with all its state
    # A ruby object's only state is its instance variables.
    # You may have to resort to meta-programming here with
    # #instance_variable_get and #instance_variable_set
    return objs unless objs.kind_of?(Array)

    serialized_objects = ""
    template = "%{variable_name}, (%{variable_value}):"

    objs.each do |object|
      # Append class name to string
      serialized_objects << "object_class:#{object.class.name}:"

      # Append each of the instance variables' name, value to string
      object.instance_variables.each do |variable|
        serialized_objects << template % {
          :variable_name => variable,
          :variable_value => serialize_objects(object.instance_variable_get(variable))
        }
      end

      serialized_objects << ";"
    end

    serialized_objects
  end

  def deserialize_objects(objs)
    # each object here is turned from a string with all its
    # state into a Ruby object
    
  end
end