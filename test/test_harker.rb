require "rubygems"
require "minitest/unit"
require 'fileutils'
require 'timeout'
require 'open-uri'

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(File.dirname(__FILE__) + "/sample/lib/")
require 'harker'

class TestHarker < MiniTest::Unit::TestCase
  ROOT = "/tmp/harker-test-#{Process.pid}"
  URL = 'http://localhost:3000/harks'

  # Ensure nothing's currently running on that port
  begin
    open(URL).read and abort "Already a process running on our port."
  rescue Errno::ECONNREFUSED # We want this to happen
  end

  def setup
    unless File.exist?(ROOT)
      Harker::GEM_ROOT.replace(File.dirname(__FILE__) + '/sample/')
      harker_action('init')
      harker_action('migrate')
    end
  end

  at_exit { FileUtils.rm_rf ROOT }

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
    begin
      harker_action('stop')
    rescue SystemExit
    end
  end

  def test_stop
    start_server_process
    assert File.exists?(ROOT + '/tmp/pids/server.pid'), "No pid found."
    Harker.launch('sample_rails', ['stop', ROOT]); sleep 0.1
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
    Harker.launch('sample_rails', [action, ROOT])
  ensure
    $stdout = STDOUT
    $stderr = STDERR
  end

  def start_server_process
    `cd #{File.dirname(__FILE__)}/.. ; ruby -I:lib:test/sample/lib test/sample/bin/sample_rails start #{ROOT} -d`
    Timeout.timeout(5) do
      loop { break if File.exist?(ROOT + '/tmp/pids/server.pid'); sleep 0.1 }
    end
    sleep 0.1 # Waiting for pid to exist isn't enough; it looks like.
  end
end

MiniTest::Unit.autorun
