require File.join(File.dirname(__FILE__), "../spec_helper.rb")
require File.join(File.dirname(__FILE__), "../../lib/player.rb")

describe Player do
  let(:joe) { Player.new("Joe") }
  let(:tim) { Player.new("Tim") }
  it "should generate unique game id" do
    joe.game_id.should_not == tim.game_id
  end
end
