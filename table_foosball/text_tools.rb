module TextTools
	def find_matching_bracket strings
		bracket_counter = 0

		strings.each do |string|
			if string.include? "["
				bracket_counter += 1
			elsif string.include? "]"
				bracket_counter -= 1
			end
		end
	end
end