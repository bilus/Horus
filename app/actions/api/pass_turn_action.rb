require File.join(File.dirname(__FILE__), "../game_action.rb")
require File.join(File.dirname(__FILE__), "../../../lib/game.rb")

class PassTurnAction < GameAction
  before_start :find_game
  on_start :pass_turn
  
  # FIXME nil or empty tiles should not be accepted.
  # FIXME only single words should be accepted.
  # NOTE: Use a separate TilePolicy class.
  def pass_turn
    render_result do
      @game.pass_turn(params[:game_id])
      {:status => :ok}
    end
    finish
  end
end
