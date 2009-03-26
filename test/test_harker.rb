require "rubygems"
require "minitest/unit"
require 'fileutils'
require 'open-uri'

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../lib/")
require 'harker'

begin
  ENV['RAILS_ENV'] = 'production'
  gem 'sample_rails'
rescue LoadError
  abort "You need the sample_rails gem installed:
  $ cd #{File.dirname(__FILE__) + '/sample'} && rake install_gem"
end

# TODO: suppress output consistently

# TODO: currently test_start and test_foreground stomp on each
# other. To get them to pass they need to run in separate processes.

class TestHarker < MiniTest::Unit::TestCase
  ROOT = "/tmp/harker-test-#{Process.pid}"
  URL = 'http://localhost:3000/harks'

  # Ensure nothing's currently running on that port
  begin
    open(URL).read and abort "Already a process running on our port."
  rescue Errno::ECONNREFUSED # We want this to happen
  end

  def setup
    # TODO: this is too slow; can we share instances between test runs?
    harker_action('init')
    harker_action('migrate')
  end

  def teardown
    FileUtils.rm_rf ROOT
  end

  def test_init
    assert File.exist?(ROOT)
    assert File.exist?(ROOT + '/database.yml')
  end

  def test_start
    start_server_process
    harks = YAML.load(open(URL).read)
    assert File.exists?(ROOT + '/tmp/pids/server.pid'), "No pid found."
    # Make sure actual DB access works.
    assert_equal ['Joy!'], harks.map{ |h| h['tidings'] }
  ensure
    harker_action('stop')
  end

  # def test_double_start
  #   start_server_process
  #   assert_match(/pidfile exists/, start_server)
  # ensure
  #   harker_action('stop')
  # end

  def test_foreground
    thread = Thread.new { harker_action('foreground') }
    sleep 2

    harks = YAML.load(open(URL).read)
    assert ! File.exists?(ROOT + '/tmp/pids/server.pid'), "Foreground wrote pid."
    assert_equal ['Joy!'], harks.map{ |h| h['tidings'] }
  ensure
    thread.kill
  end

  def test_stop
    start_server_process
    assert File.exists?(ROOT + '/tmp/pids/server.pid'), "No pid found."
    Harker.launch('sample_rails', [ROOT, 'stop'])
    assert_raises(Errno::ECONNREFUSED) { open(URL).read }
  end

  def test_migrate
    assert_equal(['id', 'tidings', 'updated_at', 'created_at'].sort,
                 Hark.columns.map{ |c| c.name }.sort)
  end

  private

  def harker_action(action)
    $stdout = StringIO.new
    $stderr = StringIO.new
    Harker.launch('sample_rails', [ROOT, action])
  ensure
    $stdout = STDOUT
    $stderr = STDERR
  end

  def start_server_process
    `cd #{File.dirname(__FILE__)}/.. ; ruby -I:lib test/sample/bin/sample_rails #{ROOT} start`
    sleep 2
  end
end

MiniTest::Unit.autorun
