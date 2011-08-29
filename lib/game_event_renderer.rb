class GameEventRenderer
  def initialize(surface, last_state = GameEventRenderer.initial_state)
    @surface = surface
    @last_state = last_state
  end
  
  def self.initial_state
    0
  end
  
  # It renders all tiles added after @last_state and returns the next state, e.g. the state
  # to correctly render only new items appended at the end of 'tiles'.
  def render_tiles(tiles)
    # pp "render_tiles(tiles.inspect) -- @last_state = #{@last_state.inspect} -- #{tiles.inspect}"
    # Skip n first elements is last state is passed (implementation detail; may change in the future).
    state = @last_state || 0
    num_to_skip = state
    new_tiles = tiles.slice(num_to_skip, tiles.length - num_to_skip)
    new_tiles.each do |t| 
      next_state = state + 1
      @surface.render_tile(t, next_state)
      state = next_state
    end
    state
  end
end
