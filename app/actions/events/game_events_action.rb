require File.join(File.dirname(__FILE__), "../../../lib/game_event_renderer")

require "pp";

class GameEventsAction < Cramp::Action
  self.transport = :sse
  before_start :find_game
  periodic_timer :relay_events, :every => 0.5
  
  def initialize(env)
    super
    preserve_last_event_id(@env, :default => GameEventRenderer.initial_state)
    # puts "initialize = #{sse_event_id}"
  end
  
  def find_game
    # puts "find_game = #{sse_event_id}"
    @game = Horus::Application.find_game
    yield
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
  def render_tile(tile, state)
    raise "State must be a number" unless state.kind_of? Integer
    @sse_event_id = state
    render(tile)
  end
  
  private
  
  def preserve_last_event_id(env, options = {})
    @sse_event_id = request_headers(env)["last_event_id"] || options.delete(:default) || sse_event
  end
  
  def request_headers(env)
    env.inject({}){|acc, (k,v)| acc[$1.downcase] = v if k =~ /^http_(.*)/i; acc}
  end
end
