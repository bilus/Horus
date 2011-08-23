def start_thin
  _in_root_dir do
    `bundle exec thin -s1 -d start`
  end
end

def stop_thin
  _in_root_dir do
    `bundle exec thin -s 1stop`
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
