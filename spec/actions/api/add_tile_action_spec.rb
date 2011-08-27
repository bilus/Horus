require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "/add_tile" do

  context_for_cramp_app do
    def app
      CrampApp::Application.routes
    end

    context "routes" do
      it "should work as POST method" do
        post "/add_tile", {}, :params => {:tile => "Lorem"} do |response|
          response[0].should == 200
          stop
        end
      end
    
      it "should not work as GET method" do
        get "/add_tile", {}, :params => {:tile => "Lorem"} do |response|
          response[0].should_not == 200
          stop
        end
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
        post "/add_tile", {}, :params => {:tile => lorem_tile}
        post "/add_tile", {}, :params => {:tile => ipsum_tile}
        game.render(renderer)
      end
    end
  end
  
end