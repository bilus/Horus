require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Api for adding tiles to game" do

  context_for_cramp_app do
    def app
      Horus::Application.routes
    end
    
    context "routes" do
      specify { "/add_tile".should_not respond_to :get, :params => {:tile => "Lorem"} } 
      specify { "/add_tile".should respond_to :post, :params => {:tile => "Lorem"} } 
    end
        
    context "when POST request is sent" do
      let!(:game1) { Horus::Application.start_new_game }
      let!(:game2) { Horus::Application.start_new_game }
    
      it "should add tile to the game" do
        renderer = mock("renderer").as_null_object
        lorem_tile, ipsum_tile = %w{Lorem ipsum}

        renderer.should_receive(:render_tiles).with([lorem_tile, ipsum_tile])
        post "/add_tile?id=#{game1.id}", {}, :params => {:tile => lorem_tile}
        post "/add_tile?id=#{game1.id}", {}, :params => {:tile => ipsum_tile}
        game1.render(renderer)
      end

      it "should add tile to the correct game game based on its id" do
        renderer = mock("renderer").as_null_object
        lorem_tile, ipsum_tile = %w{Lorem ipsum}

        renderer.should_receive(:render_tiles).with([lorem_tile])
        post "/add_tile?id=#{game1.id}", {}, :params => {:tile => lorem_tile}
        post "/add_tile?id=#{game2.id}", {}, :params => {:tile => ipsum_tile}
        game1.render(renderer)
      end
    end
  end
  
end