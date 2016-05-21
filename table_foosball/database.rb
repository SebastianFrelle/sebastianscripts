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

  def deserialize_objects(objects)
    if objects.first.last == "["
      deserialized_obj = []
      i = 1

      loop do
        k = find_next_object(objects, i) || objects.count - 1
        deserialized_obj << deserialize_objects(objects[i...k])
        break if k == objects.count - 1
        i = k
      end
    elsif objects.first.first == "object"
      klass_name = objects.first.last
      variables = {}

      i = 1
      
      while i < objects.count
        variable_name = objects[i].first.slice(/[^@].*/).to_sym

        if objects[i].last == "["
          j = find_matching_bracket(objects, i)
          variables[variable_name] = deserialize_objects(objects[i..j])
          i = j
        else
          variables[variable_name] = objects[i].last
        end

        i += 1
      end

      p variables

      deserialized_obj = Kernel.const_get(klass_name).new(variables)
    end

    deserialized_obj
  end

  def read_objects(objs)
    objects = objs.split("\n").map { |line| line.split(":", 2) }
    objects.map { |object| object.last.strip! }
    objects
  end
end