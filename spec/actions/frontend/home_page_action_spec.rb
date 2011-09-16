require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../lib/game.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Home page", :cramp => true do
  def app
    Horus::Application.routes
  end
  
  context "routes" do
    specify { get("/").should respond_with :status => :ok } 
  end
  
  context "contents" do
    let!(:games) { [Game.create("John"), Game.create("Tim"), Game.create("Joe")] }
    it "should list all pages" do
      games.each do |game|
        get("/").should respond_with :body => /.*#{game.public_id}.*/
      end
    end
  end
end