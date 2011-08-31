require 'haml'
require 'tilt'

class GamePageAction < Cramp::Action
  before_start :find_game
  on_start :start_game
  on_start :render_page
  
  def find_game
    @game = Horus::Application.find_game
    yield
  end

  def start_game
    @game.start!
  end
  
  def render_page
    render Tilt::HamlTemplate.new('app/views/game.html.haml').render
    finish
  end

end
