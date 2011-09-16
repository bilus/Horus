def start_game
  find("#new-game").click
end

def open_game
  find(".default_button").click
  wait_until { find("#game") }
  @public_game_ids ||= {}
  raise "Oops! Url format for game page has changed?" unless current_url =~ /^.*public=([^&]*).*$/
  @public_game_ids[Capybara.session_name] = $1
end

def join_game(game_owner)
  game_id = @public_game_ids[game_owner]
  find(:css, "##{game_id}").click
end

def watch_game(game_owner)
  # TODO Should probably use a "watch" link on the main page.
  visit("/game.html?game_id=#{@public_game_ids[game_owner]}")
  wait_until { find("#board") }
end

def enter_nickname
  wait_until { find("#nickname") }
  find("#nickname input#nickname").set(Capybara.session_name)
end

def add_tile(s)
  find("#game input#tile").set(s)
  find("#game #add").click
end

