require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Api for joining games", :cramp => true do
  def app
    Horus::Application.routes
  end
  let(:game) { Game.create("Tim")}
  
  context "routes" do
    specify { put("/game/#{game.public_id}", :params => {:join => "Joe"}).should respond_with :status => :ok } 
  end
  
  it "should join the game" do
    game.should_receive(:join).with("Joe")
    put("/game/#{game.public_id}", :params => {:join => "Joe"})
  end

  it "should respond with status and private game id" do
    put("/game/#{game.public_id}", :params => {:join => "Joe"}).should respond_with :body => (lambda do |body|
      params = JSON.parse(body)
      params["status"] == "ok" && params["id"] ==  game.private_id("Joe")
    end)
  end
end
