# require File.join(File.dirname(__FILE__), "../../spec_helper.rb")
require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "/game_events" do

  context_for_cramp_app do
    def app
      CrampApp::Application.routes
    end
    
    context "routes" do
      it "should work as GET method" do
        get "/game_events" do |res|
          res[0].should == 200
          stop
        end
      end
    
      it "should not work as POST method" do
        post "/game_events" do |res|
          res[0].should_not == 200
          stop
        end
      end
    end
    
    context "game" do
      before(:each) do
        CrampApp::Application.clear!
      end
      
      let(:game) { CrampApp::Application.find_game }
      
      it "should respond with added tiles" do
        game.add_tile("Lorem")
        game.add_tile("ipsum")

        action("/game_events").should respond_with_events(["Lorem", "ipsum"])
      end

      it "should respond with a story if different since the last time"
    end
  end
end