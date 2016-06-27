class Database
  def initialize(name)
    @name = name
    @filename = "./#{name}.sdb"
  end

  def clear
    File.truncate("./#{@filename}", 0)
  end

  def save(objs)
    file = File.open(@filename, "w")

    file.write(serialize_objects(objs))
    
    file.close
  end

  def load
    serialized_objs = File.read("./#{@filename}")
    return nil if serialized_objs == ""

    deserialize_objects(serialized_objs.split("\n"))
  end

  private

  def serialize_objects(objs)
    serialized_objs = ""

    case objs.class.name
    when "Array"
      serialized_objs << "[\n"
      objs.each do |object|
        serialized_objs << "#{serialize_objects(object)}\n"
      end
      serialized_objs << "]"
    when "Hash"
      serialized_objs << "{\n"
      
      objs.each do |key, value|
        serialized_objs << "#{serialize_objects(key).chomp};#{serialize_objects(value).chomp}\n"
      end
      
      serialized_objs << "}"
    else
      serialized_objs << "object:#{objs.class}"

      if !objs.instance_variables.empty?
        variables = {}
        objs.instance_variables.each do |variable_name|
          variables[variable_name] = objs.instance_variable_get(variable_name)
        end

        serialized_objs << "\n#{serialize_objects(variables)}"
      else
        serialized_objs << "=#{simple_object_serializer(objs)}"
      end
    end

    serialized_objs
  end

  def value_handler(object)
    if object.class.name == "Time"
      object.to_i
    else
      object
    end
  end

  def deserialize_objects(serialized_objs)
    # CASES
    # '---'
    #   - Initialize a new array
    #   - Keep pushing new elements to the array until a new array is initialized
    #   - How do we account for nested arrays? 
    #     By serializing the inner array as an element in the outer array
    # '----'
    #   - Initialize a new hash
    #   - Keep assigning new key/value pairs for as long as there's --
    # '<klass_name>:<value>'
    #   - Initialize object based on class name

    # i = 0
    # while i < serialized_objects.count
    #   case serialized_objects[i]
    #   when "-"
    #     # initialize element

    #   when "---"
    #     objs = []
    #     # push elements to objs array

    #   when "----"
    #     objs = {}
    #     # push following key/value pairs to hash
    #   else
    #     # make babies
    #   end
    # end

    

  end
end