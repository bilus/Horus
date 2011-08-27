require 'haml'
require 'tilt'

class HomeAction < Cramp::Action
  before_start :stop_it
  on_start :render_home
  
  def stop_it
    halt 500, {'Content-Type' => 'text/plain'}, "Invalid ID"
  end
  
  def render_home
    render Tilt::HamlTemplate.new('app/views/index.haml').render
    finish
  end

end
