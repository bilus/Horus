# Check out https://github.com/joshbuddy/http_router for more information on HttpRouter
HttpRouter.new do
  add('/').to(HomeAction)
  add('/add_tile').request_method('POST').to(AddTileAction)
  add('/game_events').request_method('GET').to(GameEventsAction)
end
