class GameEventsAction < Cramp::Action
  self.transport = :sse
  before_start :find_game
  periodic_timer :relay_events, :every => 1
  
  def find_game
    @game = CrampApp::Application.find_game
    yield
  end
  
  def relay_events
    # TODO GameEventRenderer
    @game.render_events(GameEventRenderer.new(self)) 
  end
end
