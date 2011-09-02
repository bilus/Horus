require 'haml'
require 'tilt'

class HomePageAction < Cramp::Action
  on_start :render_home
  
  def render_home
    @games = Game.find_all
    render Tilt::HamlTemplate.new('app/views/index.html.haml').render(self)
    finish
  end
end
