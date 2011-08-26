require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "/add_tile" do

  context_for_cramp_app do
    def app
      # What's possible:
      # HomeAction
      # CrampApp::Application.routes
      # nil or not override at all -> will use config.ru in the root dir.
    end

    context "routes" do
      it "should work as POST method" do
        result = post "/add_tile", :tile => "Lorem"
        result.should be_ok
      end
    
      it "should not work as GET method" do
        result = get "/add_tile", :tile => "Lorem"
        result.should_not be_ok
      end
    end
    
    context "game" do
      let(:game) { CrampApp::Application.find_game }

      before(:each) do
        CrampApp::Application.clear!
      end
    
      it "should add tile to the game" do
        renderer = mock("renderer").as_null_object
        lorem_tile, ipsum_tile = %w{Lorem ipsum}

        renderer.should_receive(:render_tiles).with([lorem_tile, ipsum_tile])
        post "/add_tile", :tile => lorem_tile
        post "/add_tile", :tile => ipsum_tile
        game.render(renderer)
      end
    end
  end
  
end