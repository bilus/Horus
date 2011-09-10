require 'uuidtools'

class Game
  @games = {}
  def initialize
    @tiles = []
    # FIXME Extract into UniqueGameId class.
    seed = UUIDTools::UUID.random_create
    @id = UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, "www.xtreeme.com/#{seed}")
    @events = []
  end
  
  def id
    @id.to_s
  end
  
  def join(nick)
    @events << {:join => nick}
  end
  
  def owner_nick
    @owner_nick
  end  
  def owner_nick=(nick)
    @owner_nick = nick
    @events << {:owner => nick}
  end
  
  def self.create(nick)
    new_game = Game.new
    new_game.owner_nick = nick
    @games[new_game.id] = new_game
    new_game
  end
  
  def self.find(id)
    @games[id]
  end
  
  def self.find_all
    @games.values
  end
  
  def self.destroy_all!
    @games.clear
  end
  
  def render(method)
    method.render_events(@events)
  end
  
  def add_tile(s)
    @tiles << s
    @events << {:tile => s}
  end
  
  def has_tiles?
    !@tiles.empty?
  end
end