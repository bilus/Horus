require 'haml'
require 'tilt'
require File.join(File.dirname(__FILE__), "../game_action.rb")

class GamePageAction < GameAction
  before_start :find_game
  on_start :render_page
  
  def render_page
    @interactive = @game.interactive?(params[:game_id])
    render Tilt::HamlTemplate.new('app/views/game.html.haml').render(self)
    finish
  end
end
