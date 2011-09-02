require File.join(File.dirname(__FILE__), "../actions_helper.rb")
require File.join(File.dirname(__FILE__), "../../../lib/game.rb")
require File.join(File.dirname(__FILE__), "../../../application")

describe "Home page" do

  context_for_cramp_app do
    def app
      Horus::Application.routes
    end

    context "routes" do
      specify { "/".should respond_to :get } 
    end
    
    context "contents" do
      let!(:games) { [Game.create, Game.create, Game.create] }
      it "should list all pages" do
        games.each do |game|
          "/".should respond_with_body(/.*#{game.id}.*/, {})
        end
      end
    end
  end
  
end