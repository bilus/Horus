require File.join(File.dirname(__FILE__), "../game_action.rb")

class NewGameAction < GameAction
  on_start :create_game
  
  def create_game
    render_result do
      new_game = Horus::Application.start_new_game(params[:nick])
      {:status => :ok, :id => new_game.private_id(params[:nick]), :public_id => new_game.public_id}
    end
    finish
  end
end
