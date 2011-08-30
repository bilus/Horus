require File.join(File.dirname(__FILE__), "../../../lib/game.rb")

class AddTileAction < Cramp::Action
  before_start :find_game
  on_start :add_tile_to_game
  
  def find_game
    @game = Horus::Application.find_game
    yield
  end
  
  # FIXME nil or empty tiles should not be accepted.
  # FIXME only single words should be accepted.
  # Use a separate TilePolicy class.
  def add_tile_to_game
    pp params
    tile = params[:tile]
    @game.add_tile(tile)
    render "ok" # FIXME Exception handling
    finish
  end

end
