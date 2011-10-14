require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Api for passing turn", :cramp => true do
  def app
    Horus::Application.routes
  end
  
  context "routes" do
    let(:game) { Game.create("Tim")}
    specify { delete("/move/#{game.private_id('Tim')}").should respond_with :status => :ok } 
  end
  
  context "-- interaction testing --" do
    let(:game) { mock("game").as_null_object }
    it "should find the game given the private game id" do
      Game.should_receive(:find).with("123").and_return(game)
      delete("/move/123")
    end
    it "should ask the game to pass for the player" do
      Game.stub!(:find).and_return(game)
      game.should_receive(:pass_turn).with("123")
      delete("/move/123")
    end
    it "should handle exception" do
      Game.stub!(:find).and_return(game)
      game.should_receive(:pass_turn).with("123").and_raise("some error")
      lambda { delete("/move/123").should respond_with :body => /.*"status":"error".*/ }.should_not raise_error
    end
  end
end
