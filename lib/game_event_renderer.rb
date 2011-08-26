class GameEventRenderer
  def initialize(surface)
    @surface = surface
  end
  
  def render(tiles)
    tiles.each {|t| @surface.render(t)}
  end
end
