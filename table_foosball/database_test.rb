require_relative './database'
require_relative './table_foosball_01'
require 'minitest/autorun'

class DatabaseTest < Minitest::Test
	def setup
		File.open("./games_test.sdb", "w") {}
		File.open("./players_test.sdb", "w") {}

		@gamedb = Database.new(:games_test)
		@playerdb = Database.new(:players_test)

		@sebastian = Player.new("Sebastian")
		@simon = Player.new("Simon")
		@daniel = Player.new("Daniel")
		@kenichi = Player.new("Kenichi")

		@game1 = Game.new([@sebastian, @simon, @daniel], [@kenichi], 10, 0)
		@game2 = Game.new([@simon], [@daniel], 6, 10)
		@game3 = Game.new([@sebastian, @simon], [@daniel, @kenichi], 10, 5)
		@game4 = Game.new([@sebastian], [@daniel, @kenichi], 10, 9)

		@players = [@sebastian, @simon, @daniel, @kenichi]
		@games = [@game1, @game2, @game3, @game4]
	end

	def teardown
		Game.games = nil
		File.delete("./games_test.sdb", "./players_test.sdb")
	end

	def test_create_new_database
		name = :test_database
		test_database = Database.new(name)
		
		assert_equal Database, test_database.class
		assert_equal name, test_database.instance_eval { @name }
		assert_equal "./#{name}.sdb", test_database.instance_eval { @filename }
	end

	def test_save_and_load_games_on_database
		assert_equal "", File.read("./games_test.sdb")
		assert_empty @gamedb.load

		@gamedb.save(@games)
		
		refute_equal "", File.read("./games_test.sdb")
		compare_object_states @games, @gamedb.load
	end

	def test_save_and_load_players_on_database
		assert_equal "", File.read("./players_test.sdb")
		assert_empty @playerdb.load

		@playerdb.save(@players)
		
		refute_equal "", File.read("./players_test.sdb")
		compare_object_states @players, @playerdb.load
	end

	private

	def compare_object_states exp, act
		exp.zip(act).each do |exp_obj, act_obj| # [[game1exp, game1act], [game2exp, game2act], ...]
			exp_obj.instance_variables.each do |variable_name|
				exp_value = exp_obj.instance_variable_get(variable_name)
				act_value = act_obj.instance_variable_get(variable_name)

				if exp_value.kind_of? Array
					compare_object_states exp_value, act_value
				else
					assert_equal exp_value.to_s, act_value.to_s
				end				
			end
		end
	end
end