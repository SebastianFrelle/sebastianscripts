require_relative "./text_tools"

class Database
  include TextTools

  def initialize(name)
    @name = name
    @file = File.open("./#{name}.sdb", "r+")
  end

  def save(objs)
    @file.rewind
    @file.write(serialize_objects(objs))
  end

  def load
    @file.rewind
    serialized_objects = @file.read
    return [] if serialized_objects == ""
    objects = read_objects(serialized_objects)
    deserialize_objects(objects)
  end

  private

  def serialize_objects(objs)
    serialized_objects = ""

    if objs.kind_of?(Array)
      serialized_objects << "[\n"

      objs.each do |object|
        serialized_objects << "#{serialize_objects(object)}"
      end

      serialized_objects << "]\n"
    elsif !objs.instance_variables.empty?
      serialized_objects << "object: #{objs.class.name}\n"

      variables = {}

      objs.instance_variables.each do |variable_name|
        variables[variable_name] = objs.instance_variable_get(variable_name)
      end

      variables.each do |variable_name, value|
        serialized_objects << "#{variable_name}: #{serialize_objects(value)}"
      end
    else
      serialized_objects << case objs.class.name
      when "String"
        "\'#{objs}\'\n"
      when "Fixnum"
        "#{objs}\n"
      else
        "#{objs.class.name}:#{objs}\n"
      end
    end

    serialized_objects
  end

  def deserialize_objects(objects)
    if objects.first.last == "["
      deserialized_obj = []
      i = 1

      loop do
        k = find_next_object(objects, i) || objects.count - 1
        puts "index of next object: #{k}"
        deserialized_obj << deserialize_objects(objects[i...k])
        break if k == objects.count - 1
        i = k
      end
    elsif objects.first.first == "object"
      p objects
      klass_name = objects.first.last
      variables = {}

      i = 1
      
      while i < objects.count
        variable_name = objects[i].first.slice(/[^@].*/).to_sym

        if objects[i].last == "["
          j = find_matching_bracket(objects, i)
          puts "index of i: #{i}"
          puts "index of matching bracket: #{j}"
          variables[variable_name] = deserialize_objects(objects[i..j])
          i = j
        else
          variables[variable_name] = value_handler(objects[i].last)
        end

        i += 1
      end

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