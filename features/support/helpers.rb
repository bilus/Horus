def start_game
  find("#new-game").click
  wait_until { find("#nickname") }
end

def confirm_start_game
  find("#nickname #ok").click
  wait_until { find("#game") }
  @games ||= {}
  @games[Capybara.session_name] = current_url
end

def join_game(game_owner)
  url = File.basename(@games[game_owner])
  find(:xpath, "//a[contains(@href, '#{url}')]").click
end

def enter_nickname
  find("#nickname input#nickname").set(Capybara.session_name)
end

def add_tile(s)
  find("#game input#tile").set(s)
  find("#game #add").click
end

