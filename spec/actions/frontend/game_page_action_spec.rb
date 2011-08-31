require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Game page" do

  context_for_cramp_app do
    def app
      Horus::Application.routes
    end

    context "routes" do
      specify { "/game.html".should respond_to :get } 
    end
    
  end
  
end