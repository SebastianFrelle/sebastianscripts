class Database
  def initialize(name)
    @name = name
    @file = File.open("./#{name}.sdb", "w") # sebastiandb
  end

  def save(objs)
    @file.write(serialize_objects(objs))
  end

  def load
    return [] 
    # deserialize_objects(@file.readlines)
  end

  private

  def serialize_objects(objs)
    # each object in here needs to be turned into a string
    # with all its state
    # A ruby object's only state is its instance variables.
    # You may have to resort to meta-programming here with
    # #instance_variable_get and #instance_variable_set

    serialized_objects = ""
    template = "instance_variable_%{number}:%{value};"


    objs.each do |object|
      serialized_objects << "object_class:#{object.class.name};"
      
      counter = 1
      serialized_variables = ""

      object.instance_variables.each do |variable|
        serialized_variables << template % {
          :number => counter,
          :value => object.instance_variable_get(variable)
        }

        counter += 1
      end

      serialized_objects << serialized_variables << "\n"
    end

    serialized_objects
  end

  def deserialize_objects(objs)
    # each object here is turned from a string with all its
    # state into a Ruby object

    
  end
end
