require File.join(File.dirname(__FILE__), "../../../lib/game.rb")

class AddTileAction < Cramp::Action
  before_start :find_game
  on_start :add_tile_to_game
  
  def find_game
    @game = CrampApp::Application.find_game
    yield
  end
  
  def add_tile_to_game
    tile = params[:tile]
    @game.add_tile(tile)
    render "ok" # FIXME Exception handling
    finish
  end

end
