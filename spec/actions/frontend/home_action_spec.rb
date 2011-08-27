require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "/" do

  context_for_cramp_app do
    def app
      CrampApp::Application.routes
    end

    context "routes" do
      it "should work as GET method" do
        get "/" do |response|
          response[0].should == 200
          stop
        end
      end
    end
  end
  
end