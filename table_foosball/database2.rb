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

    deserialize_objects(serialized_objs)
  end

  private

  def serialize_objects(objs)
    serialized_objs = ""

    case objs.class.name
    when "Array"
      serialized_objs << "---"
      objs.each do |object|
        serialized_objs << "\n-\n#{serialize_objects(object)}"
      end
    when "Hash"
      serialized_objs << "----\n"
      
      objs.each do |key, value|
        serialized_objs << "--\n#{serialize_objects(key).chomp};#{serialize_objects(value).chomp}\n"
      end

      serialized_objs.chomp!
    else
      serialized_objs << "#{objs.class}"
      
      if !objs.instance_variables.empty?
        variables = {}
        objs.instance_variables.each do |variable_name|
          variables[variable_name] = objs.instance_variable_get(variable_name)
        end

        serialized_objs << "\n#{serialize_objects(variables)}"
      else
        serialized_objs << ":#{objs}"
      end
    end

    serialized_objs
  end

  def deserialize_objects(objs)
    # CASES
    # '---'
    #   - Initialize a new array
    #   - Keep pushing new elements to the array until a new array is initialized
    #   - How do we account for nested arrays?
    #   - By serializing the inner array as an element in the outer array
    # '----'
    #   - Initialize a new hash
    #   - Keep assigning new key/value pairs for as long as there's --
    # '<klass_name>:<value>'
    #   - Initialize object based on class name

    
  end
end