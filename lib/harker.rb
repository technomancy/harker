require 'fileutils'

# Harker lets you deploy Rails apps via RubyGems.
#
# These commands get invoked by the bin wrapper of the rails app gem
# rather than by Harker itself.
#
module Harker
  VERSION = '0.5.2'
  ACTIONS = %w(start stop restart init migrate console)
  GEM_ROOT = Gem.loaded_specs[File.basename($0)].full_gem_path rescue '.'

  module_function

  # Dispatch based on user's command
  def launch(name, args)
    action = args.shift

    unless ACTIONS.include?(action)
      abort "Usage: #{name} (#{ACTIONS.join('|')}) [INSTANCE_DIR] [START_ARGS]
The start command takes the same arguments as script/server."
    end

    # We need to get rid of the first arg if it's the optional
    # instance directory so script/server doesn't get confused.
    @root = if File.directory? args.first.to_s or action == 'init'
              File.expand_path args.shift
            else
              Dir.pwd
            end

    @name = name

    unless action == 'init'
      # 2.3.2 doesn't support tmp_dir config option; needs a monkeypatch.
      require 'harker/rails_configuration'
      require @name
      Dir["#{@root}/extensions/*rb"].each { |f| load f }
    end

    self.send(action)
  end

  # Start and optionally daemonize the application server
  def start
    # http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2350
    # Submitted a patch to Rails, but this lets it work with 2.3.2
    Rails::Rack::LogTailer::EnvironmentLog.replace(Rails.configuration.log_path)

    abort "Can't start; pidfile exists at #{pidfile}." if File.exist? pidfile
    require 'harker/server'
  end

  def stop
    abort "No pid at #{pidfile}." unless File.exist?(pidfile)
    Process.kill('TERM', File.read(pidfile).to_i)
  end

  def restart
    stop
  rescue SystemExit
    start
  end

  # Initialize a new instance of your application
  def init
    %w(tmp log db extensions).each do |d|
      FileUtils.mkdir_p(File.join(@root, d))
    end

    base_db_file = File.join(GEM_ROOT, 'config', 'database.yml')

    File.open("#{@root}/database.yml", 'w') do |fp|
      # Need to make sure any sqlite3 DB paths are absolute.
      db_config = YAML.load_file(base_db_file)
      db_config.each do |env, hash|
        if hash['adapter'] =~ /sqlite3?/
          hash['database'] = File.join(@root, hash['database'])
        end
      end

      fp.puts(db_config.to_yaml)
    end

    puts <<-END
    Initialized #{@name} instance in #{@root}...
    
    Configure your database by editing #{@root}/database.yml.
    Optionally configure your web server via rack in #{@root}/config.ru.
    
    Migrate your DB with: #{@name} migrate
    Then launch with: #{@name} start --daemon
    END
  end

  def migrate
    puts "Migrating the #{RAILS_ENV} environment of #{@name}..."
    ActiveRecord::Migrator.migrate(File.join(Rails.root, 'db', 'migrate'),
                                   ENV["VERSION"] && ENV["VERSION"].to_i)
  end

  def console
    require 'irb'
    IRB.start
  end

  def configure(config)
    config.database_configuration_file = File.join(@root, 'database.yml')
    config.log_path = File.join(@root, 'log', "#{RAILS_ENV}.log")
    config.tmp_dir = File.join(@root, 'tmp')
  end

  def pidfile
    File.join(@root, 'tmp', 'pids', 'server.pid')
  end
end
