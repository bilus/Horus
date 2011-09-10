require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Game page", :cramp => true do
  def app
    Horus::Application.routes
  end

  context "routes" do
    specify { get("/game.html?game_id=1234").should respond_with :status => :ok } 
  end
end