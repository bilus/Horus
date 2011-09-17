require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Api for adding tiles to game", :cramp => true do
  def app
    Horus::Application.routes
  end
  
  context "-- basic integration testing --" do
    let!(:game1) { Horus::Application.start_new_game("Joe") }
    let!(:game2) { Horus::Application.start_new_game("Joe") }
  
    it "should add tile to the game" do
      renderer = mock("renderer").as_null_object
      lorem_tile, ipsum_tile = %w{Lorem ipsum}

      renderer.should_receive(:render_events).with([{:owner => "Joe"}, {:tile => lorem_tile}, {:tile => ipsum_tile}])
      post "/tile/#{game1.private_id('Joe')}", :params => {:tile => lorem_tile}
      post "/tile/#{game1.private_id('Joe')}", :params => {:tile => ipsum_tile}
      game1.render(renderer)
    end

    it "should add tile to the correct game game based on a private id" do
      renderer = mock("renderer").as_null_object
      lorem_tile, ipsum_tile = %w{Lorem ipsum}

      renderer.should_receive(:render_events).with([{:owner => "Joe"}, {:tile => lorem_tile}])
      post "/tile/#{game1.private_id('Joe')}", :params => {:tile => lorem_tile}
      post "/tile/#{game2.private_id('Joe')}", :params => {:tile => ipsum_tile}
      game1.render(renderer)
    end
  end
  
  context "-- interaction testing --" do
    let!(:game) { mock("game").as_null_object }
    
    before(:each) do
      Game.stub!(:find).and_return(game)
    end
    
    # Interaction testing.
    it "should add tile to the game" do
      game.should_receive(:add_tile).with("Lorem", "1234")
      post "/tile/1234", :params => {:tile => "Lorem"}
    end
    
    it "should handle exception" do
      game.should_receive(:add_tile).with("Lorem", "1234").and_raise("some error")
      lambda { post("/tile/1234", :params => {:tile => "Lorem"}).should respond_with :body => /.*"status":"error".*/ }.should_not raise_error
    end
  end
end
