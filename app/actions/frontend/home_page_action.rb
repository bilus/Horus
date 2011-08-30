require 'haml'
require 'tilt'

class HomePageAction < Cramp::Action
  before_start :find_game
  on_start :start_game
  on_start :render_home
  
  def find_game
    @game = Horus::Application.find_game
    yield
  end

  def start_game
    @game.start!
  end
  
  def render_home
    render Tilt::HamlTemplate.new('app/views/index.html.haml').render
    finish
  end

end
