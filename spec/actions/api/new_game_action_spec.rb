require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Api for creating new games" do

  context_for_cramp_app do
    def app
      Horus::Application.routes
    end
    
    context "routes" do
      specify { "/game".should respond_to :post } 
    end
        
    context "game creation" do      
      it "should start a new game when invoked" do
        Horus::Application.should_receive(:start_new_game).once
        post "/game"
      end
      
      it "should respond with new game id" do
        Horus::Application.stub!(:start_new_game).and_return("new game id")
        "/game".should respond_with_body /.*"id":"new game id".*/, :method => :post
      end
      
      it "should render error information if exception is raised" do
        Horus::Application.stub!(:start_new_game).and_raise("an error")
        "/game".should respond_with_body /.*an error.*/, :method => :post
      end
    end
  end
  
end