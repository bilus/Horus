require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "/game_events", :cramp => true do
  def app
    Horus::Application.routes
  end
  
  def events_including(events)
    test = proc do |chunks|
      body = chunks.join
      events.select do |k, v|
        r = /.*"#{k.to_s}":"#{v}".*/
        (body =~ r) != nil
      end.length == events.length
    end
    {:chunks => test}
  end
  
  context "routes" do
    let!(:game) { Horus::Application.start_new_game("Joe") }
    specify { post("/game/#{game.public_id}").should_not respond_with :status => :ok }
  end
  
  context "game events for" do
    context "a single game" do
      let!(:game) { Horus::Application.start_new_game("Joe") }
      let(:joe_id) { game.private_id("Joe") }
      it "should initially respond with game owner" do
        get("/game/#{game.public_id}", :max_chunks => 1).should respond_with events_including(:owner => "Joe")
      end
    
      it "should respond with added tiles" do
        game.add_tile("Lorem", joe_id)
        game.add_tile("ipsum", joe_id)
        get("/game/#{game.public_id}", :max_chunks => 6).  # owner, next_turn, tile, next_turn, tile, next_turn
          should respond_with events_including(:tile => "Lorem", :tile => "ipsum")
      end

      it "should respond with a story if different since the last time based on last event id" do
        game.add_tile("Lorem", joe_id)
        game.add_tile("ipsum", joe_id)
        last_event_id = ""
        get("/game/#{game.public_id}", :max_chunks => 6). # owner, next_turn, tile, next_turn, tile, next_turn
          should respond_with(:chunks => lambda do |chunks|
            chunks.last =~ /.*^id: (.*)$.*/
            last_event_id = $1
            true
          end)
        game.add_tile("dolor", joe_id)
        game.add_tile("sit", joe_id)
        game.add_tile("amet", joe_id)
        get("/game/#{game.public_id}", :max_chunks => 6, :headers => {"Last-Event-Id" => last_event_id}).
          should respond_with events_including(:tile => "dolor", :tile => "sit", :tile => "amet")
      end
    end
    
    context "multiple games" do
      let!(:game1) { Horus::Application.start_new_game("Joe") }
      let!(:game2) { Horus::Application.start_new_game("Joe") }
      
      it "should respond with a different story based on game id" do
        game1.add_tile("Lorem", game1.private_id("Joe"))
        game1.add_tile("ipsum", game1.private_id("Joe"))
        game2.add_tile("Hello", game2.private_id("Joe"))
        game2.add_tile("world", game2.private_id("Joe"))
        get("/game/#{game1.public_id}", :max_chunks => 6). # owner, next_turn, tile, next_turn, tile, next_turn
          should respond_with events_including(:tile => "Lorem", :tile => "ipsum")
        get("/game/#{game2.public_id}", :max_chunks => 6). # same as above
          should respond_with events_including(:tile => "Hello", :tile => "world")
      end
    end
  end
end
