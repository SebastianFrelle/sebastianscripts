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
    @file.rewind
    deserialize_objects(@file.read)
    return []
  end

  private

  def serialize_objects(objs) # Take an array of objects
    serialized_objects = ""
    template = "(%{object_class_name}:%{value})"

    objs.each do |object|
      variables = object.instance_variables.map do |variable_name|
        object.instance_variable_get(variable_name)
      end
      
      if object.kind_of?(Array)
        value = serialize_objects(object)
      elsif object.instance_variables.empty?
        value = object
      else
        value = serialize_objects(variables)
      end

      serialized_objects << template % {
        :object_class_name => object.class.name,
        :value => value
      }
    end

    serialized_objects
  end

  def deserialize_objects(objs)

  end
end