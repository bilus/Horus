# TODO Start thin in a separate thread? 
#
# Currently it triggers "Illegal instruction"
# 
# def start_thin
#   @server_thread = Thread.new do
#     begin
#       # Dir.chdir(File.join(File.dirname(__FILE__), "../../"))
#       options = {:server => 'thin', :Port => 3000, :config => 'config.ru'}
#       Rack::Server.start(options)
#     rescue => e
#       puts "Error in server thread: #{e}\n#{e.backtrace.join("\n")}"
#       throw
#     end
#   end
#   @server_thread.run
# 
#   sleep(2) # TODO Ugly: simply sleep for some time.
# end
# 
# def stop_thin
#   @server_thread.kill if @server_thread
# end


def start_thin
  _in_root_dir do
    `bundle exec thin -s1 -d start`
  end
end

def stop_thin
  _in_root_dir do
    `bundle exec thin -s1 stop`
  end
end

def _in_root_dir
  old_dir = Dir.pwd
  root_dir = File.join(File.dirname(__FILE__), "../..")
  Dir.chdir(root_dir)
  begin
    yield
  ensure
    Dir.chdir(old_dir)
  end
end
