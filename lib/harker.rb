require 'fileutils'

# Harker lets you deploy Rails apps via RubyGems.
module Harker
  VERSION = '0.0.2'
  ACTIONS = %w(start stop restart init migrate console foreground)

  module_function

  # Dispatch based on user's command
  def launch(name, args)
    @root = File.expand_path(args.shift || Dir.pwd)
    @name = name

    action = args.shift

    unless ACTIONS.include?(action)
      abort "Usage: #{@name} INSTANCE_DIR (#{ACTIONS.join('|')})"
    end

    load_app unless action == 'init'
    self.send(action)
  end

  # Start the application server in the foreground.
  def foreground
    start(false)
  end

  # Start and daemonize the application server
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

    # TODO: use the in-gem copy of database.yml as a base for this
    File.open("#{@root}/database.yml", 'w') do |fp|
      # TODO: be smart about environments; bleh
      fp.puts({ 'production' => { 'adapter' => 'sqlite3',
                  'database' => @root + '/db.sqlite3',
                  'pool' => 5, 'timeout' => 5000 }}.to_yaml)
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
    ActiveRecord::Migrator.migrate(RAILS_ROOT + '/db/migrate',
                                   ENV["VERSION"] && ENV["VERSION"].to_i)
  end

  def console
    require 'irb'
    IRB.start
  end

  def configure(config)
    config.database_configuration_file = File.join(@root, 'database.yml')
    config.log_path = File.join(@root, 'log', "#{RAILS_ENV}.log")

    # 2.3.2 doesn't support tmp_dir config option.
    require 'harker/rails_configuration' unless config.respond_to?(:tmp_dir=)
    config.tmp_dir = File.join(@root, '/tmp')
  end

  def load_app
    require @name
  end

  def pidfile
    File.join(@root, 'tmp', 'pids', 'server.pid')
  end
end
