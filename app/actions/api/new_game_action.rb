require 'json'
require File.join(File.dirname(__FILE__), "../../../application.rb")

class NewGameAction < Cramp::Action
  on_start :create_game
  
  def create_game
    response = 
      begin
        new_game = Horus::Application.start_new_game
        {:status => :ok, :id => new_game.id}
      rescue => e
        {:status => :error, :message => e}
      end
    render response.to_json
    finish
  end
end
