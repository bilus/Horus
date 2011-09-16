require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "/game_events", :cramp => true do
  def app
    Horus::Application.routes
  end
  
  def tiles(tiles)
    {:chunks => tiles.map {|tile| /.*"tile":"#{tile}".*/}}
  end
  
  def owner(nick)
    {:chunks => [/.*"owner":"#{nick}".*/]}
  end
  
  context "routes" do
    let!(:game) { Horus::Application.start_new_game("Joe") }
    specify { post("/game/#{game.public_id}").should_not respond_with :status => :ok }
  end
  
  context "game events for" do
    context "a single game" do
      let!(:game) { Horus::Application.start_new_game("Joe") }
    
      it "should initially respond with game owner" do
        get("/game/#{game.public_id}", :max_chunks => 1).should respond_with owner "Joe"
      end
    
      it "should respond with added tiles" do
        game.add_tile("Lorem")
        game.add_tile("ipsum")
        get("/game/#{game.public_id}", :max_chunks => 3).  # 1 owner + 2 tiles
          should respond_with :chunks => (owner("Joe")[:chunks] + tiles(["Lorem", "ipsum"])[:chunks])
      end

      it "should respond with a story if different since the last time based on last event id" do
        game.add_tile("Lorem")
        game.add_tile("ipsum")
        last_event_id = ""
        get("/game/#{game.public_id}", :max_chunks => 3).should respond_with(:chunks => lambda do |chunks|
          chunks.last =~ /.*^id: (.*)$.*/
          last_event_id = $1
          true
        end)
        game.add_tile("dolor")
        game.add_tile("sit")
        game.add_tile("amet")
        get("/game/#{game.public_id}", :max_chunks => 3, :headers => {"Last-Event-Id" => last_event_id}).
          should respond_with tiles ["dolor", "sit", "amet"]
      end
    end
    
    context "multiple games" do
      let!(:game1) { Horus::Application.start_new_game("Joe") }
      let!(:game2) { Horus::Application.start_new_game("Joe") }
      
      it "should respond with a different story based on game id" do
        game1.add_tile("Lorem")
        game1.add_tile("ipsum")
        game2.add_tile("Hello")
        game2.add_tile("world")
        get("/game/#{game1.public_id}", :max_chunks => 3). # 1 owner + 2 tiles
          should respond_with :chunks => (owner("Joe")[:chunks] + tiles(["Lorem", "ipsum"])[:chunks])
        get("/game/#{game2.public_id}", :max_chunks => 3). # 1 owner + 2 tiles
          should respond_with :chunks => (owner("Joe")[:chunks] + tiles(["Hello", "world"])[:chunks])
      end
    end
  end
end
