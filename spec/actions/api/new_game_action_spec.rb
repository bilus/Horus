require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Api for creating new games", :cramp => true do
  def app
    Horus::Application.routes
  end
  
  context "routes" do
    specify { post("/game").should respond_with :status => :ok } 
  end
      
  context "game creation" do      
    let(:new_game) { g = mock("game"); g.stub!(:id).and_return("sample game id"); g }
    
    it "should start a new game when invoked" do
      Horus::Application.should_receive(:start_new_game).once
      post "/game"
    end
    
    it "should respond with new game id" do
      Horus::Application.stub!(:start_new_game).and_return(new_game)
      post("/game").should respond_with :body => /.*"id":"#{new_game.id}".*/
    end
    
    it "should render error information if exception is raised" do
      Horus::Application.stub!(:start_new_game).and_raise("an error")
      post("/game").should respond_with :body => /.*an error.*/
    end
  end
end
