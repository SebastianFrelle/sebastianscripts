require_relative './database'
require 'minitest/autorun'

class DatabaseTest < Minitest::Test
	def setup
		@playerdb = Database.new(:players_test)
		@gamedb = Database.new(:games_test)
	end

	def teardown
		
	end

	def test_create_new_database
		database = Database.new(:database_test)
		assert_equal :database_test, database.instance_eval{ @name }
	end

end