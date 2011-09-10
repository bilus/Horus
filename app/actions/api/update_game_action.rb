require File.join(File.dirname(__FILE__), "../game_action.rb")

class UpdateGameAction < GameAction
  before_start :find_game
  on_start :update_game

  def update_game
    render_result do
      if params[:join]
        @game.join(params[:join])
        {:status => :ok, :id => @game.id}
      else
        {:status => :error}
      end
    end
    finish
  end
end
