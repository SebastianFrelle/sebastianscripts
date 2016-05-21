module TextTools
	def find_matching_bracket(strings, index)
		bracket_count = 1
		j = index

		until bracket_count == 0
			j += 1
			if strings[j].last == "["
				bracket_count += 1
			elsif strings[j].last == "]"
				bracket_count -= 1
			end
		end

		j
	end

	def find_next_object(strings, index)
		return nil unless strings[index].first == "object"

		bracket_count = 1

		for i in index+1...strings.count
			return i if bracket_count == 1 && strings[i].first == "object"

			if strings[i].last == "["
				bracket_count += 1
			elsif strings[i].last == "]"
				bracket_count -= 1
			end
		end

		nil
	end
end