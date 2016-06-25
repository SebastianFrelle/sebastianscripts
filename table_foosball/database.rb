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
    file = File.open(@filename, "r")
    file.rewind

    serialized_objects = file.read

    return nil if serialized_objects == ""

    objects = read_objects(serialized_objects)

    deserialize_objects(objects)
  end

  private

  def serialize_objects(objs)
    serialized_objects = ""

    if objs.kind_of?(Array)
      serialized_objects << "["

      objs.each do |object|
        serialized_objects << "#{serialize_objects(object)}"
      end

      serialized_objects << "]\n"
    elsif !objs.instance_variables.empty?
      serialized_objects << "\nobject:#{objs.class.name}\n{\n"

      variables = {}

      objs.instance_variables.each do |variable_name|
        variables[variable_name] = objs.instance_variable_get(variable_name)
      end

      variables.each do |variable_name, value|
        serialized_objects << "#{variable_name}:#{serialize_objects(value)}"
      end

      serialized_objects << "}\n"
    else
      serialized_objects << case objs.class.name
      when "String"
        "\'#{objs}\'\n"
      when "Fixnum"
        "#{objs}\n"
      when "Time"
        "Time:#{objs.to_i}\n"
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
        if objects[i].first == "["
          k = find_matching_bracket(objects, i) + 1
        else
          k = find_next_object(objects, i) || objects.count - 1
        end
        deserialized_obj << deserialize_objects(objects[i...k])

        break if k == objects.count - 1
        i = k
      end
    elsif objects.first.last.split(":").first == "object"
      klass_name = objects.first.last
      object_klass = Kernel.const_get(klass_name)
      deserialized_obj = object_klass.allocate
      
      variables = {}

      i = 1
      while i < objects.count
        variable_name = objects[i].first.slice(/[^@].*/).to_sym

        if objects[i].last == "["
          j = find_matching_bracket(objects, i)
          variables[variable_name] = deserialize_objects(objects[i..j])
          i = j
        else
          variables[variable_name] = value_handler(objects[i].last)
        end

        i += 1
      end

      variables.each do |name, value|
        deserialized_obj.instance_variable_set("@#{name}", value)
      end

    else
      deserialized_obj = value_handler(objects)
    end

    deserialized_obj
  end

  def read_objects(input_lines)
    objects = input_lines.split("\n").map do |line|
      line.split(":", 2)
    end

    objects
  end

  def find_matching_bracket(strings, index)
    bracket_count = 1

    for j in index+1...strings.count
      if strings[j].last == "["
        bracket_count += 1
      elsif strings[j].last == "]"
        bracket_count -= 1
      end
      return j if bracket_count == 0
    end

    j
  end

  def find_next_object(strings, index)
    bracket_count = 1

    for i in index+1...strings.count
      return i if bracket_count == 1 && strings[i].first[0] != '@'

      if strings[i].last == "["
        bracket_count += 1
      elsif strings[i].last == "]"
        bracket_count -= 1
      end
    end
    nil
  end

  def find_matching_brace(strings, index)
    bracket_count = 1

    for j in index+1...strings.count
      if strings[j].last == "{"
        bracket_count += 1
      elsif strings[j].last == "}"
        bracket_count -= 1
      end
      return j if bracket_count == 0
    end

    j
  end

  def value_handler value_string
    if value_string.kind_of? String
      value_string = value_string.split(":", 2)
    end

    value_string.flatten!

    string_regex = /[^']*[^']/

    unless (value_string.last =~ string_regex) == 0
      value = value_string.last.slice(string_regex)
    else
      if value_string.first == "Time"
        value = Time.at(value_string.last.to_i)
      else
        value = value_string.last.to_i
      end
    end

    value
  end
end