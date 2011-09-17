require File.join(File.dirname(__FILE__), "unique_id")

class Player
  def initialize(nick)
    @nick = nick
    @game_id = UniqueId.new.to_s
  end
  def nick
    @nick
  end
  def game_id
    @game_id
  end
end