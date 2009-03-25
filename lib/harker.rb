require 'fileutils'

# Harker lets you deploy Rails apps via RubyGems
module Harker
  VERSION = '0.0.1'
  ACTIONS = %w(start stop restart init migrate console)

  module_function

  # Dispatch based on user's command
  def launch(name, args)
    @root = args.shift || Dir.pwd
    @name = name

    action = args.shift
    
    unless ACTIONS.include?(action)
      abort("Usage: #{@name} INSTANCE_DIR (#{ACTIONS.join('|')})")
    end

    load_app
    self.send(action)
  end

  # Start the server
  def start
    # TODO: this needs to be way more configurable
    Rack::Handler::Mongrel.run(ActionController::Dispatcher.new,
                               :Port => 9292, :Host => "0.0.0.0", :AccessLog => [])
  end

  # Stop the server
  def stop
    raise "Not implemented yet; sorry!" # TODO
  end

  # Stop and start the application server
  def restart
    stop
    start
  end

  # Initialize a new instance of your application
  def init
    FileUtils.mkdir_p(@root)
    FileUtils.mkdir_p(@root + '/log')
    FileUtils.mkdir_p(@root + '/tmp')
    FileUtils.cp("#{RAILS_ROOT}/config/database.yml", "#{@root}/database.yml")
    puts "Initialized #{@name} instance in #{@root}..."
    puts "Migrate with: #{@name} migrate"
    puts "Then launch with: #{@name} start"
  end

  # Perform all pending migrations for this instance
  def migrate
    ActiveRecord::Migrator.migrate(RAILS_ROOT + '/db',
                                   ENV["VERSION"] && ENV["VERSION"].to_i)
  end

  # Run script/console
  def console
    require 'commands/console'
  end

  # :nodoc:
  def load_app
    # TODO: teach Rails to honor the instance's db.yml, log/ and tmp/
    require name
  end
end
