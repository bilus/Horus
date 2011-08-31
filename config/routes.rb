# Check out https://github.com/joshbuddy/http_router for more information on HttpRouter
HttpRouter.new do
  add('/').to(HomePageAction)
  add('/index.html').to(HomePageAction)
  
# Legacy interface
  add('/add_tile').request_method('POST').to(AddTileAction)
  add('/game_events').request_method('GET').to(GameEventsAction)

# RESTful interface
  # add('/game').request_method('POST').to(NewGameAction)
  add('/game.html').request_method('GET').to(GamePageAction)
  add('/game').request_method('PUT').to(AddTileAction)
  add('/game').request_method('GET').to(GameEventsAction)
  
end
