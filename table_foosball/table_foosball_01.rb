require "securerandom"

class Player
  def initialize name
    @name = name

    @timestamp = Time.now
    @id = SecureRandom.uuid
  end

  attr_reader :name, :timestamp, :id

  def games
    Game.all.select { |game| game.players.include?(self) }
  end

  def won_games
    games.select { |game| game.winner.include?(self) }
  end

  def lost_games
    games.select {|game| game.loser.include?(self)}
  end

  def games_against(opponent)
    games.select { |game| game.opponents.include?(opponent) }
  end

  def most_frequent_opponent(games = self.games)
    all_opponents = games.map { |game| game.opponents(self) }.flatten
    all_opponents.group_by { |player| player.name }.max_by { |player, games| games.count }.first
  end

  def most_wins_against
    most_frequent_opponent won_games
  end

  def most_losses_against
    most_frequent_opponent lost_games
  end

end

class Game
  def self.all
    @games
  end

  def self.create(side1, side2, side1score, side2score)
    @games ||= []
    @games << Game.new(side1, side2, side1score, side2score)
    @games.last
  end

  def initialize side1, side2, side1score, side2score
    @side1 = side1
    @side2 = side2

    @side1score = side1score
    @side2score = side2score

    @timestamp = Time.now
    @id = SecureRandom.uuid
  end

  attr_accessor :side1, :side2, :side1score, :side2score, :timestamp, :id

  def players
    @side1 + @side2
  end

  def winner
    (@side1score > @side2score) ? @side1 : @side2
  end

  def loser
    return (winner == @side1) ? @side2 : @side1
  end

  def opponents player
    @side1.include?(player) ? @side2 : @side1
  end
end

### testing

sebastian = Player.new("Sebastian")
daniel = Player.new("Daniel")
simon = Player.new("Simon")
kenichi = Player.new("Kenichi")

# Game.create([sebastian, kenichi], [simon], 10, 0)
# Game.create([sebastian], [simon], 10, 7)
# Game.create([sebastian], [kenichi, simon], 5, 3)
# Game.create([sebastian, daniel], [simon, kenichi], 2, 6)

p Game.create([@sebastian], [@simon], 10, 0)
