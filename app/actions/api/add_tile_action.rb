require File.join(File.dirname(__FILE__), "../game_action.rb")
require File.join(File.dirname(__FILE__), "../../../lib/game.rb")

class AddTileAction < GameAction
  before_start :find_game
  on_start :add_tile_to_game
  
  # FIXME nil or empty tiles should not be accepted.
  # FIXME only single words should be accepted.
  # NOTE: Use a separate TilePolicy class.
  def add_tile_to_game
    render_result do
      tile = params[:tile]
      @game.add_tile(tile)
      {:status => :ok}
    end
    finish
  end
end
