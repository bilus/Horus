require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Home page" do

  context_for_cramp_app do
    def app
      CrampApp::Application.routes
    end

    context "routes" do
      specify { "/".should respond_to :get } 
    end
  end
  
end