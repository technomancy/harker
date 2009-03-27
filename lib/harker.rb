require 'fileutils'

# Harker lets you deploy Rails apps via RubyGems.
#
# These commands get invoked by the bin wrapper of the rails app gem
# rather than by Harker itself.
#
module Harker
  VERSION = '0.0.3'
  ACTIONS = %w(start stop restart init migrate console foreground)

  module_function

  # Dispatch based on user's command
  def launch(name, args)
    action = args.shift

    unless ACTIONS.include?(action)
      abort "Usage: #{name} INSTANCE_DIR (#{ACTIONS.join('|')})"
    end

    @root = File.expand_path(args.shift || Dir.pwd)
    @name = name

    require @name unless action == 'init'
    self.send(action)
  end

  # Start the application server in the foreground.
  def foreground
    start(false)
  end

  # Start and optionally daemonize the application server
  def start(daemonize = true)
    # can has internal consistency plz, Rails?
    Rails::Rack::LogTailer::EnvironmentLog.replace(Rails.configuration.log_path)
    # http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2350
    # Submitted a patch to Rails, but this lets it work with 2.3.2

    ARGV.replace ["--config=#{@root}/config.ru"]
    ARGV.push('--daemon') if daemonize
    
    abort "Can't start; pidfile exists at #{pidfile}." if File.exist? pidfile
    require 'harker/server'
  end

  def stop
    abort "No pid at #{pidfile}." unless File.exist?(pidfile)
    Process.kill('TERM', File.read(pidfile).to_i)
  end

  def restart
    stop
    start
  end

  # Initialize a new instance of your application
  def init
    FileUtils.mkdir_p(@root)
    FileUtils.mkdir_p(@root + '/log')
    FileUtils.mkdir_p(@root + '/tmp')
    FileUtils.mkdir_p(@root + '/db') # In case we use sqlite.

    base_db_file = File.join(File.dirname($0), '..', 'config', 'database.yml')

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

    # TODO: write a default config.ru?

    puts "Initialized #{@name} instance in #{@root}..."
    puts
    puts "Configure your database by editing #{@root}/database.yml."
    puts "Optionally configure your web server via rack in #{@root}/config.ru."
    puts
    puts "Migrate your DB with: #{@name} migrate"
    puts "Then launch with: #{@name} start"
  end

  def migrate
    puts "Migrating the #{RAILS_ENV} environment of #{@name}..."
    ActiveRecord::Migrator.migrate(File.join(RAILS_ROOT, 'db', 'migrate'),
                                   ENV["VERSION"] && ENV["VERSION"].to_i)
  end

  def console
    require 'irb'
    IRB.start
  end

  def configure(config)
    config.database_configuration_file = File.join(@root, 'database.yml')
    config.log_path = File.join(@root, 'log', "#{RAILS_ENV}.log")

    # 2.3.2 doesn't support tmp_dir config option; needs a monkeypatch.
    require 'harker/rails_configuration' unless config.respond_to?(:tmp_dir=)
    config.tmp_dir = File.join(@root, '/tmp')
  end

  def pidfile
    File.join(@root, 'tmp', 'pids', 'server.pid')
  end
end
