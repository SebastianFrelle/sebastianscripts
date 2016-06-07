require_relative "./database"
require "securerandom"

class Player
  class << self
    def players
      @players ||= database.load || []
    end

    def players=(player_set)
      @players = player_set
    end

    def create(name)
      players << Player.new(name)
      persist(players)
      players.last
    end

    def by_name(name)
      players.find { |player| player.name.downcase == name.downcase }
    end    
  end

  def initialize(name)
    @name = name
    @timestamp = Time.now
    @id = SecureRandom.uuid
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

  private

  def self.database
    @database ||= Database.new(:players)
  end

  def self.persist(objs)
    database.save(objs)
  end

  def self.clear
    @database.clear
    self.players = nil
  end
end

class Game
  class << self
    def games
      @games ||= database.load || []
    end

    def games=(game_set)
      @games = game_set
    end

    def clear
      database.clear
      self.games = nil
    end

    alias_method :all, :games
    alias_method :all=, :games=

    def create(side1, side2, side1score, side2score)
      games << Game.new(side1, side2, side1score, side2score)
      persist(games)
      games.last
    end
  end

  def initialize(side1, side2, side1score, side2score)
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
  
  private

  def self.database
    @database ||= Database.new(:games)
  end

  def self.persist(objs)
    database.save(objs)
  end
end