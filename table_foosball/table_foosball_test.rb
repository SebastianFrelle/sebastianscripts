require_relative "./table_foosball_01"
require 'minitest/autorun'

class FoosballTest < Minitest::Test
  def setup
    @sebastian = Player.new("Sebastian")
    @daniel = Player.new("Daniel")
    @simon = Player.new("Simon")
    @kenichi = Player.new("Kenichi")
  end

  def teardown
    Game.games = []
  end

  def test_create_new_player
    frederik = Player.new("Frederik")
    
    assert_equal "Frederik", frederik.name
    refute_nil frederik.timestamp
    refute_nil frederik.id
    
    assert_empty frederik.games
  end

  def test_create_game_with_two_players
    game = Game.create([@sebastian], [@simon], 10, 0)
    
    assert_equal [@sebastian, @simon], game.players
    assert_equal [@sebastian], game.winner
    assert_equal [@simon], game.loser

    assert_equal 10, game.side1score
    assert_equal 0, game.side2score

    assert_equal [game], @sebastian.games
    assert_equal [game], @simon.games
  end

  def test_create_game_with_multiple_players
    game = Game.create([@simon], [@daniel, @kenichi], 10, 0)
    assert_equal [@simon, @daniel, @kenichi], game.players
    assert_equal [@simon], game.winner
    assert_equal [@daniel, @kenichi], game.loser
  end

  def test_get_player_opponents
    game = Game.create([@simon], [@daniel, @kenichi], 10, 8)
    assert_equal [@daniel, @kenichi], game.opponents(@simon)
  end

  def test_get_player_game_statistics
    game1 = Game.create([@simon], [@daniel, @kenichi], 10, 0)
    game2 = Game.create([@sebastian, @simon], [@daniel], 10, 4)
    game3 = Game.create([@simon, @kenichi, @sebastian], [@daniel], 10, 9)
    game4 = Game.create([@simon, @kenichi, @daniel], [@sebastian], 10, 8)

    assert_equal [game2, game3, game4], @sebastian.games
    assert_equal [game2, game3], @sebastian.won_games
    assert_equal [game4], @sebastian.lost_games

  end

  def test_get_player_vs_player_statistics
    game1 = Game.create([@simon], [@daniel, @kenichi], 10, 0)
    game2 = Game.create([@sebastian, @simon], [@daniel], 10, 4)
    game3 = Game.create([@simon, @kenichi, @sebastian], [@daniel], 10, 9)
    game4 = Game.create([@simon, @kenichi, @daniel], [@sebastian], 10, 8)

    assert_equal [game1, game2, game3], @simon.games_against(@daniel)
    assert_equal @daniel, @simon.most_frequent_opponent
    assert_equal @daniel, @simon.most_wins_against
    assert_equal nil, @simon.most_losses_against
  end
end