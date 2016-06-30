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
        serialized_objs << "-\n#{serialize_objects(object)}\n"
      end
      serialized_objs << "]"
    when "Hash"
      serialized_objs << "{\n"
      
      objs.each do |key, value|
        serialized_objs << "--\n(\n---\n#{serialize_objects(key).chomp}\n---\n#{serialize_objects(value).chomp}\n)\n"
      end
      
      serialized_objs << "}"
    else
      serialized_objs << "object;#{objs.class}"

      if !objs.instance_variables.empty?
        variables = {}
        objs.instance_variables.each do |variable_name|
          variables[variable_name] = objs.instance_variable_get(variable_name)
        end

        serialized_objs << "\n#{serialize_objects(variables)}"
      else
        serialized_objs << ";#{value_handler(objs)}"
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

  def deserialize_objects(objs)
    if objs.first[-1] == '['
      deserialized_objs = []

      i = 1
      while true
        break if objs[i] == ']'
        j = next_element_index(objs, '[', i) || objs.length
        deserialized_objs << deserialize_objects(objs[i+1...j])

        break if j >= objs.length
        i = j
      end
    elsif objs.first[-1] == '{'
      deserialized_objs = {}

      i = 1
      while true
        break if objs[i] == '}'

        j = next_element_index(objs, '{', i) || objs.length - 1
        
        key, value = deserialize_objects(objs[i+1...j])
        
        deserialized_objs[key] = value
        
        break if j >= objs.length - 1
        i = j
      end
    elsif objs.first == '('
      deserialized_objs = deserialize_key_value_pair(objs)
    elsif /^object/ =~ objs.first
      object_data = objs.first.split(";", 3) # Parameter for at accounte for tomme strings
      klass_name = object_data[1]

      if object_data.length == 2 # Hvis objektet ikke har en value, der kan parses, men har instansvariable
        deserialized_objs = Kernel.const_get(klass_name).allocate
        
        variables = deserialize_objects(objs[1..-1])
        
        variables.each do |variable_name, variable_value|
          deserialized_objs.instance_variable_set(variable_name, variable_value)
        end
      else
        deserialized_objs = case klass_name
        when "Fixnum"
          object_data[2].to_i
        when "Time"
          Time.at(object_data[2].to_i)
        when "Symbol"
          object_data[2].to_sym
        when "String"
          object_data[2]
        else
          raise 'Class unknown/not supported by database'
        end
      end
    end
    
    deserialized_objs
  end

  def deserialize_key_value_pair(objs)
    i = 1
    pair = []

    2.times do
      j = next_element_index(objs, '(', i) || objs.length - 1
      pair << deserialize_objects(objs[i+1...j])
      i = j
    end

    pair
  end

  def next_element_index(objs, opening_delim, pos)
    closing_delim, char = case opening_delim
    when '['
      [']', '-']
    when '{'
      ['}', '--']
    when '('
      [')', '---']
    else
      raise 'Invalid delimiter'
    end

    level = 1

    objs[pos+1..-1].each_with_index do |object, index|
      return index + pos + 1 if level == 1 && object == char

      if object == closing_delim
        level -= 1
      elsif object[-1] == opening_delim
        level += 1
      end
    end
    nil
  end

end