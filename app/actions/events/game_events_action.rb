require File.join(File.dirname(__FILE__), "../../../lib/game_event_renderer")

class GameEventsAction < Cramp::Action
  self.transport = :sse
  before_start :find_game
  periodic_timer :relay_events, :every => 1
  
  def find_game
    @game = CrampApp::Application.find_game
    yield
  end
  
  def relay_events
    # STDERR.puts "relay_events"
    # render "Lorem"
    # render "ipsum"
    @game.render(GameEventRenderer.new(self)) 
  end
  
  # GameEventRenderer calls the render function but in Cramp::Action it's protected.
  # I'm removing the protection here as I believe it's the easiest thing to do.
  def render(what)
    # STDERR.puts "action > #{what}"
    super(what)
  end
end
