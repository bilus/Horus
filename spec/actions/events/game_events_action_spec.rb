require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "/game_events" do

  context_for_cramp_app do
    def app
      Horus::Application.routes
    end
    
    context "routes" do
      specify { "/game_events".should respond_to :get } 
      specify { "/game_events".should_not respond_to :post }
    end
    
    context "game events for" do
      context "a single game" do
        let!(:game) { Horus::Application.start_new_game }
      
        it "should respond with added tiles" do
          game.add_tile("Lorem")
          game.add_tile("ipsum")
          "/game_events?id=#{game.id}".should respond_with_events([/.*Lorem.*/, /.*ipsum.*/], {})
        end

        it "should respond with a story if different since the last time based on last event id" do
          game.add_tile("Lorem")
          game.add_tile("ipsum")
          last_event_id = ""
          "/game_events?id=#{game.id}".should respond_with_events([/.*Lorem.*/, /.*ipsum.*/], :on_each => proc { |data, event_id| last_event_id = event_id})
          game.add_tile("dolor")
          game.add_tile("sit")
          game.add_tile("amet")
          "/game_events?id=#{game.id}".should respond_with_events([/.*dolor.*/, /.*sit.*/, /.*amet.*/], :last_event_id => last_event_id)
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
          "/game_events?id=#{game1.id}".should respond_with_events([/.*Lorem.*/, /.*ipsum.*/], {})
          "/game_events?id=#{game2.id}".should respond_with_events([/.*Hello.*/, /.*world.*/], {})
        end
      end
    end
  end
end