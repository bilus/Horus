require File.join(File.dirname(__FILE__), "game_events")

class GameState
  def initialize(events = nil)
    @players = []
    @events = events || GameEvents.new
  end
  
  def join(player, &block)
    @players << player
    block.call if block
    @events.on_join(player.nick)
  end
  
  def join_owner(player, &block)
    @players << player
    block.call if block
    @events.on_owner(player.nick)
    next_turn(player)
  end
  
  def add_tile(t, game_id, &block)
    raise "Not allowed to play" unless interactive?(game_id)
    raise "Not your turn" unless turn_of?(game_id)
    block.call if block
    @events.on_add_tile(t)
    next_turn(next_player(@current_player))
  end
  
  def interactive?(game_id)
    @players.find {|p| p.game_id == game_id}
  end
  
  def render_using(method)
    @events.render_using(method)
  end
  
  private
    
  def turn_of?(game_id)
    @current_player.game_id == game_id
  end
  
  def next_turn(player)
    @current_player = player
    @events.on_next_turn(player.nick)
  end
  
  def next_player(player)
    index = @players.index(player)
    if index
      @players[(index + 1) % @players.size]
    else
      @players.first
    end
  end
end