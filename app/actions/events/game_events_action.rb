require File.join(File.dirname(__FILE__), "../game_action.rb")
require File.join(File.dirname(__FILE__), "../../../lib/game_event_renderer")

class GameEventsAction < GameAction
  self.transport = :sse
  before_start :find_game
  periodic_timer :relay_events, :every => 0.5
  
  def initialize(env)
    super
    preserve_last_event_id(@env, :default => GameEventRenderer.initial_state)
    # puts "initialize = #{sse_event_id}"
  end
  
  def relay_events
    # pp @sse_event_id
    # TODO Remove in production -->
    # Test code to terminate the action every 5 relays.
    # @repeats ||= 0
    # finish if (@repeats += 1) >= 5
    # <--
    @game.render(GameEventRenderer.new(self, @sse_event_id.to_i)) 
  end
  
  # Renderer needs to preserve state between each call. Because this action object can be 
  # destroyed and re-created at any point, we cannot use an instance variable to preserve state.
  # But event id is ideal for this as long as the state is a number.
  def render_event(event, state)
    raise "State must be a number" unless state.kind_of? Integer
    @sse_event_id = state
    render(event.to_json)
  end
  
  private
  
  def preserve_last_event_id(env, options = {})
    @sse_event_id = request_headers["last_event_id"] || options.delete(:default) || sse_event
  end
end
