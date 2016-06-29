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
        serialized_objs << "--\nkey;#{serialize_objects(key).chomp}=value;#{serialize_objects(value).chomp}\n"
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
    # if ['[', '{'].include? objs.first # eventuelt. Bare for mindre redundancy.
    if objs.first == '['
      deserialized_objs = []

      i = 1
      while true
        j = next_element_index(objs, '[', i) || objs.length
        deserialized_objs << deserialize_objects(objs[i+1...j])

        break if j >= objs.length
        i = j
      end
    elsif objs.first == "{"
      deserialized_objs = {}

      i = 1
      while true
        # Hvordan serialiserer vi key/value pairs her?
        j = next_element_index(objs, '{', i) || objs.length
        # deserialized_objs << deserialize_objects(objs[i+1...j])
        # deserialized_objs[<deserialized_key>] = <deserialized_value>
        # Parse arrayet til en metode, der deserializer hele det pair
        # Det fungerer kun, hvis vi så returnerer parret som en hash 
        #   { :key => blah, :value => blah}
        # eller som en array
        #   [key, value]
        # Hvorfor har vi brug for det?
        # Fordi vi allerede har den del af teksten, der beskriver det par.
        # Det er én eller flere linjer, men under alle omstændigheder har
        # vi allerede fundet blokken. Det er det, der gør det til den letteste løsning.

        # key, value = objs.split('=').map { |object| object.split(';', 2)[1] }
        # deserialized_objs = deserialize_objects([key, value])

        break if j >= objs.length
        i = j
      end
    elsif /^object/ =~ objs.first
      object_data = objs.first.split(";")
      klass_name = object_data[1]

      if object_data.length == 2
        deserialized_objs = klass_name.allocate

        # Instansvariable her. Identificér den blok, der indeholder instansvariable
        # Den løber fra { på næste linje til } på en anden linje. Pointen er, at
        # blokken skal deserialiseres som en hash, vis værdier så gemmes i objektet som instansvariable
      else
        # Idé: Opret det simple objekt her ved at parse værdien ved noget med #eval
      end
    end
    
    deserialized_objs
  end

  def deserialize_key_value_pair(objs)
    pair = {}
    
  end

  def deserialize_key_value_pair(objs)
    hash = {}
    # Den 2. parameter på #split er ikke nødvendig, hvis vi bruger en anden
    # delim end ';' til at adskille keyword og værdi
    key, value = objs.split('=').map { |object| object.split(';', 2)[1] }
    hash[deserialize_objects(key)] = deserialize_objects(value)
  end

  def matching_delimiter(objs, opening_delim, pos)
    closing_delim = case opening_delim
    when '{'
      '}'
    when '['
      ']'
    else
      raise ArgumentError, 'Invalid delimiter'
    end

    level = 1

    objs[pos+1..-1].each_with_index do |index, object|
      if object == closing_delim
        level -= 1
        return index if level == 0
      elsif object[-1] == opening_delim
        level += 1
      end
    end
  end

  def next_element_index(objs, opening_delim, pos)
    closing_delim, char = case opening_delim
    when '{'
      ['}', '--']
    when '['
      [']', '-']
    else
      raise ArgumentError, 'Invalid delimiter'
    end

    level = 1

    objs[pos+1..-1].each_with_index do |index, object|
      return index if level == 1 && object == char

      if object == closing_delim
        level -= 1
      elsif object[-1] == opening_delim
        level += 1
      end
    end
  end

end