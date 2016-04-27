require_relative "./table_foosball_01"
require 'minitest/autorun'

class FoosballTest < Minitest::Test
  def setup
    @sebastian = Player.new("Sebastian")
    @daniel = Player.new("Daniel")
    @simon = Player.new("Simon")
    @kenichi = Player.new("Kenichi")
  end

  def test_create_game_with_two_players
    game = Game.create([@sebastian], [@simon], 10, 0)
    assert_equal [@sebastian], game.winner
  end

  # more tests
end