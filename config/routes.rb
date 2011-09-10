# Check out https://github.com/joshbuddy/http_router for more information on HttpRouter
HttpRouter.new do
  add('/').to(HomePageAction)
  add('/index.html').to(HomePageAction)
  
# Legacy interface
  add('/game_events').get.to(GameEventsAction)

# RESTful interface
  add('/game').post.to(NewGameAction)
  add('/game.html').get.to(GamePageAction)
  add('/tile/:game_id').post.to(AddTileAction)
  # add('/game').matching(:new => /^.+$/).request_method('PUT').to(HomePageAction)
  add('/game/:game_id').get.to(GameEventsAction)
  
end
