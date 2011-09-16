require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Api for creating new games", :cramp => true do
  def app
    Horus::Application.routes
  end
  
  context "routes" do
    specify { post("/game?nick=Joe").should respond_with :status => :ok } 
  end
      
  let(:public_id) {"public-id"}
  let(:private_id) {"private-id"}
  let(:new_game) do 
    g = mock("game")
    g.stub!(:public_id).and_return(public_id)
    g.stub!(:private_id).and_return(private_id)
    g
  end    
  
  it "should start a new game" do
    Horus::Application.should_receive(:start_new_game).once
    post "/game?nick=Joe"
  end
  
  it "should start a new game passing the nick name" do
    Horus::Application.should_receive(:start_new_game).with("Joe").once
    post "/game?nick=Joe"
  end
  
  it "should respond with ok status" do
    Horus::Application.stub!(:start_new_game).and_return(new_game)
    post("/game?nick=Joe").should respond_with :body => /.*"status":"ok".*/
  end  
  
  it "should respond with new private game id" do
    Horus::Application.stub!(:start_new_game).and_return(new_game)
    post("/game?nick=Joe").should respond_with :body => /.*"id":"#{private_id}".*/
  end

  it "should respond with new public game id" do
    Horus::Application.stub!(:start_new_game).and_return(new_game)
    post("/game?nick=Joe").should respond_with :body => /.*"public_id":"#{public_id}".*/
  end
  
  it "should respond with an error if starting new game fails" do
    Horus::Application.stub!(:start_new_game).and_raise("some error")
    post("/game?nick=Joe").should respond_with :body => /.*"status":"error".*/
    post("/game?nick=Joe").should respond_with :body => /.*"message":"some error".*/
  end
end
