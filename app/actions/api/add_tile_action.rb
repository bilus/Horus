class AddTileAction < Cramp::Action
  before_start :find_game
  on_start :add_tile_to_game
  
  def find_game
    # @game = CrampApp::Application.find_game
    yield
  end
  
  def add_tile_to_game
    tile = params[:tile]
    @game.add_tile(tile) # TODO add_title
    render "ok" # TODO Exception handling
    finish
  end

end
