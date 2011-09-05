require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "/game_events", :cramp => true do
  def app
    Horus::Application.routes
  end
  
  context "routes" do
    let!(:game) { Horus::Application.start_new_game }
    specify { post("/game_events?id=#{game.id}").should_not respond_with :status => :ok }
  end
  
  context "game events for" do
    context "a single game" do
      let!(:game) { Horus::Application.start_new_game }
    
      it "should respond with added tiles" do
        game.add_tile("Lorem")
        game.add_tile("ipsum")
        get("/game_events?id=#{game.id}", :max_chunks => 2).should respond_with :chunks => [/.*^data: Lorem$.*/, /.*^data: ipsum$.*/]
      end

      it "should respond with a story if different since the last time based on last event id" do
        game.add_tile("Lorem")
        game.add_tile("ipsum")
        last_event_id = ""
        get("/game_events?id=#{game.id}", :max_chunks => 2).should respond_with(:chunks => lambda do |chunks|
          chunks.last =~ /.*^id: (.*)$.*/
          last_event_id = $1
          true
        end)
        game.add_tile("dolor")
        game.add_tile("sit")
        game.add_tile("amet")
        get("/game_events?id=#{game.id}", :max_chunks => 3, :headers => {"Last-Event-Id" => last_event_id}).
          should respond_with :chunks => [/.*dolor.*/, /.*sit.*/, /.*amet.*/]
      end
    end
    
    context "multiple games" do
      let!(:game1) { Horus::Application.start_new_game }
      let!(:game2) { Horus::Application.start_new_game }
      
      it "should respond with a different story based on game id" do
        game1.add_tile("Lorem")
        game1.add_tile("ipsum")
        game2.add_tile("Hello")
        game2.add_tile("world")
        get("/game_events?id=#{game1.id}", :max_chunks => 2).should respond_with :chunks => [/.*^data: Lorem$.*/, /.*^data: ipsum$.*/]
        get("/game_events?id=#{game2.id}", :max_chunks => 2).should respond_with :chunks => [/.*^data: Hello$.*/, /.*^data: world$.*/]
      end
    end
  end
end
