class GameEvents
  def initialize
    @events = []
  end
  
  def on_join(nick)
    @events << {:join => nick}
  end
  
  def on_owner(nick)
    @events << {:owner => nick}
  end
  
  def on_add_tile(tile)
    @events << {:tile => tile}
  end
  
  def on_next_turn(nick)
    @events << {:next_turn => nick}
  end
  
  def render_using(method)
    method.render_events(@events)
  end
end