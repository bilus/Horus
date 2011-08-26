require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "/game_events" do

  context_for_cramp_app do
    def app
      # What's possible:
      # HomeAction
      # CrampApp::Application.routes
      # nil or not override at all -> will use config.ru in the root dir.
    end
    

    
    context "routes" do
      it "should work as GET method" do
        result = get "/game_events"
        result.should be_ok
      end
    
      it "should not work as POST method" do
        result = post "/game_events"
        result.should_not be_ok
      end
    end
    
    context "game" do
      before(:each) do
        CrampApp::Application.clear!
      end
      
      let(:game) { CrampApp::Application.find_game }
      
      it "should respond with empty story for a new game" do
        result = get "/game_events"
        result.body.should == ""
      end
      
      it "should respond with a story after adding tiles" do
        game.add_tile("Lorem")
        game.add_tile("ipsum")
        result = get "/game_events"
        result.body.should == "Lorem ipsum"
      end
      
      it "should respond with a story if different since the last time"
    end
  end
end