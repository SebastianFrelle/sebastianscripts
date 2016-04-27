require_relative "./table_foosball_01"
require 'minitest/autorun'

class FoosballTest < Minitest::Test
  def setup
    @sebastian = Player.new("Sebastian")
    @daniel = Player.new("Daniel")
    @simon = Player.new("Simon")
    @kenichi = Player.new("Kenichi")
  end
end