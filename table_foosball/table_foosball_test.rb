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
    assert_equal [@sebastian, @simon], game.players
    assert_equal [@sebastian], game.winner
    assert_equal [@simon], game.loser
  end

  def test_create_game_with_multiple_players
    game = Game.create([@sebastian, @daniel], [@simon, @kenichi], 10, 0)
    assert_equal [@sebastian, @daniel, @simon, @kenichi], game.players
    assert_equal [@sebastian, @daniel], game.winner
    assert_equal [@simon, @kenichi], game.loser
  end

  def test_create_game_with_asymmetrical_no_of_players
    game = Game.create([@sebastian], [@simon, @daniel], 8, 2)
    assert_equal [@sebastian], game.winner
    assert_equal [@simon, @daniel], game.loser
  end

  def test_won_games
    game1 = Game.create([@simon, @daniel, @kenichi], [@sebastian], 10, 2)
    game2 = Game.create([@simon, @daniel], [@sebastian, @kenichi], 10, 6)
    game3 = Game.create([@simon, @daniel], [@sebastian, @kenichi], 10, 7)
    game4 = Game.create([@simon, @kenichi], [@daniel], 10, 6)
    assert_equal [game1, game2, game3, game4], @simon.won_games
    assert_equal [], @sebastian.won_games
    assert_equal [game1, game2, game3], @sebastian.games_against(@simon)
  end

  def test_lost_games
    game1 = Game.create([@simon, @daniel, @kenichi], [@sebastian], 10, 2)
    game2 = Game.create([@simon, @daniel], [@sebastian, @kenichi], 10, 6)
    game3 = Game.create([@simon, @daniel], [@sebastian, @kenichi], 10, 7)
    game4 = Game.create([@simon, @kenichi], [@daniel], 10, 6)
    assert_equal [game1, game2, game3], @sebastian.lost_games
    assert_equal "Simon", @sebastian.most_losses_against
  end

  def test_get_player_opponents
    game1 = Game.create([@simon, @daniel, @kenichi], [@sebastian], 10, 2)
    game2 = Game.create([@simon, @daniel], [@sebastian, @kenichi], 10, 6)
    game3 = Game.create([@simon, @daniel], [@sebastian, @kenichi], 10, 7)
    game4 = Game.create([@simon, @kenichi], [@daniel], 10, 6)
    assert_equal [@simon, @daniel, @kenichi], game1.opponents(@sebastian)
  end
end