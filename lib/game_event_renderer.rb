class GameEventRenderer
  def initialize(surface, last_state = GameEventRenderer.initial_state)
    @surface = surface
    @last_state = last_state
  end
  
  def self.initial_state
    0
  end
  
  # It renders all events added after @last_state and returns the next state, e.g. the state
  # to correctly render only new items appended at the end of 'events'.
  def render_events(events)
    # pp "render_tiles(tiles.inspect) -- @last_state = #{@last_state.inspect} -- #{tiles.inspect}"
    # Skip n first elements is last state is passed (implementation detail; may change in the future).
    state = @last_state || 0
    num_to_skip = state
    new_events = events.slice(num_to_skip, events.length - num_to_skip)
    new_events.each do |e| 
      next_state = state + 1
      @surface.render_event(e, next_state)
      state = next_state
    end
    state
  end
end
