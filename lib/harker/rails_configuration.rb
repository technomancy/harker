# This monkeypatches Rails to allow tmp_dir to be configured.

# It's been submitted upstream:
# http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2379

# We can remove the Configuration monkeypatch once the above patch is
# accepted if we don't care about supporting older versions.

gem 'rails'
require 'initializer'

class Rails::Configuration
  attr_accessor :tmp_dir

  def default_tmp_dir
    File.join(root_path, 'tmp')
  end

  def default_cache_store
    if File.exist? File.join(default_tmp_dir, 'cache')
      [ :file_store, File.join(default_tmp_dir, 'cache') ]
    else
      :memory_store
    end
  end
end

class Rails::Initializer
  def self.run(command = :process, configuration = Rails::Configuration.new)
    yield configuration if block_given?
    Harker.configure(configuration)
    initializer = new configuration
    initializer.send(command)
    initializer
  end
end
