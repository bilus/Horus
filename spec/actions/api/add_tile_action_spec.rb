require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../application")
# require "em-synchrony"
# require "rack"
# require "rack/test"

require 'pp'

describe "/add_tile" do

    
  context_for_cramp_app do
    def app
      # What's possible:
      # HomeAction
      # CrampApp::Application.routes
      # nil or not override at all -> will use config.ru in the root dir.
    end
    
    it 'TODO get rid of this after adding more tests, it is here to illustrate the concept.' do
      response = get "/"
      response.should be_ok
      response.body.should include("Type a word")
    end
    
    it "should work as POST method" do
      result = post "/add_tile", :tile => "Lorem"
      result.should be_ok
      result.body.should == "ok"
    end
    
    it "should not work as GET method" do
      result = get "/add_tile", :tile => "Lorem"
      result.should_not be_ok
    end
    # it "should not work as GET method" do
    #   get_body_chunks "/" do |body|
    #     # status.should == 200
    #     body[0].should == "ok: Lorem"
    #     stop
    #   end
    # end      
    # it "should add tile to the current game"
  end
  
end