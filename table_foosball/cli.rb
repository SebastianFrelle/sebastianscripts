require_relative "./table_foosball_01"
require "thor"

class TableFoosballCLI < Thor

  desc "create_new_game", "creates a new game interactively"
  long_desc <<-LONGDESC
  create_new_game interactively takes the user through the process of creating a new game, asking for user input corresponding to each variable as it goes along.
  LONGDESC
  def create_new_game
    side1 = ask("Players on side 1:")
    side1 = side1.split(", ").map { |player_name| Player.by_name(player_name) }

    side2 = ask("Players on side 2:")
    side2 = side2.split(", ").map { |player_name| Player.by_name(player_name) }

    side1score = ask("Side 1's score:").to_i
    side2score = ask("Side 2's score:").to_i

    print "Creating game..."
    Game.create(side1, side2, side1score, side2score)
    puts "Done!"
  end

  desc "show_all_games", "show all games"
  def show_all_games
    Game.games.each { |game| p game }
  end

  desc "clear_games", "clear all games from database"
  def clear_games
    Game.clear
  end

  desc "create_new_player PLAYER_NAME", "creates a new player named PLAYER_NAME"
  long_desc <<-LONGDESC
  `create_new_player` will create a new player with a name of your choosing.
  LONGDESC
  def create_new_player(player_name)
    print "Creating new player #{player_name}..."
    Player.create(player_name)
    puts "Done!"
  end

  desc "show_all_players", "show all players"
  long_desc <<-LONGDESC
  `show_all_players` shows all players currently in the database.
  LONGDESC
  def show_all_players
    Player.players.each { |player| p player }
  end

  desc "clear_players", "clear all players"
  def clear_players
    Player.clear
  end
end

TableFoosballCLI.start(ARGV)