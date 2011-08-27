require 'haml'
require 'tilt'

class HomeAction < Cramp::Action
  on_start :render_home
  
  def render_home
    render Tilt::HamlTemplate.new('app/views/index.haml').render
    finish
  end

end
