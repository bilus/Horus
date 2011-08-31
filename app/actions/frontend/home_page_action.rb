require 'haml'
require 'tilt'

class HomePageAction < Cramp::Action
  on_start :render_home
  
  def render_home
    render Tilt::HamlTemplate.new('app/views/index.html.haml').render
    finish
  end
end
