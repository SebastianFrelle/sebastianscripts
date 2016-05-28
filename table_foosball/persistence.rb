module Persistence
	def objects
		@objects ||= database.load
	end

	def objects=(object_set)
		@objects = object_set
	end

	private

	def database
		@database ||= Database.new(name.downcase + "s")
	end

	def persist objects
		@database.save(objects)
	end
end