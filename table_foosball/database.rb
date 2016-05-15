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

    if objs.kind_of?(Array)
      serialized_objects << "[\n"

      objs.each do |object|
        serialized_objects << "#{serialize_objects(object)}"
      end

      serialized_objects << "]\n"
    elsif !objs.instance_variables.empty?
      serialized_objects << "object: #{objs.class.name}\n"

      variables = Hash.new

      objs.instance_variables.each do |variable_name|
        variables[variable_name] = objs.instance_variable_get(variable_name)
      end

      variables.each do |variable_name, value|
        serialized_objects << "#{variable_name}: #{serialize_objects(value)}"
      end
    else
      serialized_objects << "#{objs}\n"
    end

    serialized_objects
  end

  def deserialize_objects(objs)
    
  end
end