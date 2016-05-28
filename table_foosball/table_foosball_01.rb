require_relative "./database"
require_relative "./persistence"
require "securerandom"

class Player
  extend Persistence

  class << self
    alias_method :players, :objects
    alias_method :players=, :objects=

    def create(*args)
      players << Player.new(*args)
      persist(players)
      players.last
    end

    def by_name(name)
      players.each do |player|
        return player if player.name.downcase == name.downcase
      end
    end
  end

  def initialize(*args)
    case args.first.class.name
    when 'Hash'
      args[0].each { |k, v| send("#{k}=", v) }
    else
      @name = args.first
      @timestamp = Time.now
      @id = SecureRandom.uuid
    end
  end

  attr_accessor :name, :timestamp, :id

  def games
    Game.all.select { |game| game.players.include?(self) }
  end

  def won_games
    games.select { |game| game.winner.include?(self) }
  end

  def lost_games
    games.select { |game| game.loser.include?(self) }
  end

  def games_against(opponent)
    games.select { |game| game.opponents(self).include?(opponent) }
  end

  def most_frequent_opponent(game_set = self.games)
    return nil if game_set.empty?

    all_opponents = game_set.map { |game| game.opponents(self) }.flatten
    all_opponents.group_by { |player| player }.max_by { |player, games| games.count}.first
  end

  def most_wins_against
    most_frequent_opponent won_games
  end

  def most_losses_against
    most_frequent_opponent lost_games
  end
end

class Game
  extend Persistence

  class << self
    alias_method :all, :objects
    alias_method :games=, :objects=

    alias_method :games, :all

    def create(*args)
      games << Game.new(*args)
      persist(games)
      games.last
    end
  end

  def initialize(*args)
    case args.first.class.name
    when 'Hash'
      args[0].each { |k,v| send("#{k}=", v) }
    else
      @side1, @side2, @side1score, @side2score = args
      @timestamp = Time.now
      @id = SecureRandom.uuid
    end
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