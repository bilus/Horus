require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Api for adding tiles to game", :cramp => true do
  def app
    Horus::Application.routes
  end
  
  context "when POST request is sent" do
    let!(:game1) { Horus::Application.start_new_game("Joe") }
    let!(:game2) { Horus::Application.start_new_game("Joe") }
  
    it "should add tile to the game" do
      renderer = mock("renderer").as_null_object
      lorem_tile, ipsum_tile = %w{Lorem ipsum}

      renderer.should_receive(:render_events).with([{:owner => "Joe"}, {:tile => lorem_tile}, {:tile => ipsum_tile}])
      post "/tile/#{game1.id}", :params => {:tile => lorem_tile}
      post "/tile/#{game1.id}", :params => {:tile => ipsum_tile}
      game1.render(renderer)
    end

    it "should add tile to the correct game game based on its id" do
      renderer = mock("renderer").as_null_object
      lorem_tile, ipsum_tile = %w{Lorem ipsum}

      renderer.should_receive(:render_events).with([{:owner => "Joe"}, {:tile => lorem_tile}])
      post "/tile/#{game1.id}", :params => {:tile => lorem_tile}
      post "/tile/#{game2.id}", :params => {:tile => ipsum_tile}
      game1.render(renderer)
    end
  end
end
