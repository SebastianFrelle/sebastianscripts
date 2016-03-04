require "securerandom"

class Player
  def initialize name
    @name = name
    @games = [] # what are all the games this player has been involved in?
    
    # IDEAS for attributes
    # - Time stamp for creation of this player object
    # - UUID because multiple players might have similar names
    @timestamp = Time.now
    @id = ID.get_id
  end

  attr_reader :name, :games, :timestamp, :id

  # return all the games this player won in
  def won_games
    @games.select {|g| g.winner.include? self}
  end

  # return all the games this player lost in
  def lost_games
    @games.select {|g| g.loser.include? self}
  end
  
  # return all the games this player has played against opponent o
  def no_of_games_against o
    @games.select { |g| g.get_opponents(self).include? o }.length
  end

  # __The following applies to all of the following methods__
  # Problem, tho. Returns the first key to hold the max value; ignores rest if same value as max
  # Return table of player objects/IDs instead, or maybe just false or nil?

  # return the opponent this player has played the most games against
  def most_games_against
    most_freq_opp @games
  end

  # return the opponent this player has most frequently won against
  def most_wins_against
    most_freq_opp won_games
  end

  # most frequently lost against
  def most_losses_against
    most_freq_opp lost_games
  end
  ####

  private # methods below this point are private

  def most_freq_opp arr
    if !arr.empty?
      opponents = Hash.new(0)

      arr.each do |g|
        opp = g.get_opponents(self) # Consider making independent of get_opponents method
        opp.map { |o| opponents[o] += 1 }
      end

      opponents.max_by { |k,v| v }[0]
    end
  end
end

# BONUS: what if there are more than two players in a game?
# IDEA
# - Take table of player objects as argument with size in range (2..6)
# - Take side1 as argument first, then side2
# - Each parameter side1, side2 is array of player objects with size in range (1..3)
# - ...messes with most_freq_opp and its derivative methods in Player
#   - Make get_opponent return array of player objects instead?
#   - Map functions in player class to get_opponent array accordingly
class Game
  def initialize side1, side2, side1score, side2score
    ### side1, side2 should be array of player objects
    @side1 = side1
    @side2 = side2
    
    # side1score, side2score should be integers, their sum <= 19
    # - If a full game has taken place, one of these will be ==10. Just a thought.
    @side1score = side1score
    @side2score = side2score

    ### Additional methodology
    # assign winning and losing sides
    @winner = winner
    @loser = loser
    # add game to player objects' @games arrays
    @side1.map { |p| p.games << self }
    @side2.map { |p| p.games << self }
    
    ### OTHER ATTRIBUTES
    # Time and date
    @timestamp = Time.now
    # UUID
    @id = ID.get_id
  end

  attr_reader :side1, :side2, :side1score, :side2score, :timestamp, :id
  
  def winner
    if @winner.nil?
      return (@side1score > @side2score) ? @side1 : @side2
    end

    @winner
  end

  def loser
    if @loser.nil?
      return (winner == @side1) ? @side2 : @side1
    end

    @loser
  end
  
  def get_opponents player
    @side1.include?(player) ? @side2 : @side1
  end
end

class ID
  def self.get_id
    SecureRandom.uuid
  end
end

### testing

sebastian = Player.new("Sebastian")
daniel = Player.new("Daniel")
simon = Player.new("Simon")
kenichi = Player.new("Kenichi")

game1 = Game.new([sebastian, kenichi], [simon], 10, 0)
game2 = Game.new([sebastian], [simon], 10, 7)
game3 = Game.new([sebastian], [kenichi, simon], 5, 3)
game4 = Game.new([sebastian,daniel], [simon, kenichi], 2, 6)