require "rubygems"
require "minitest/unit"
require 'fileutils'

require File.dirname(__FILE__) + "/../lib/harker"

begin
  ENV['RAILS_ENV'] = 'production'
  gem 'sample_rails'
rescue LoadError
  abort "You need the sample_rails gem installed:
  $ cd #{File.dirname(__FILE__) + '/sample'} && rake install_gem"
end

class TestHarker < MiniTest::Unit::TestCase
  ROOT = "/tmp/harker-test-#{Process.pid}"

  def setup
    suppress_out { Harker.launch('sample_rails', [ROOT, 'init']) }
  end

  def teardown
    FileUtils.rm_rf ROOT
  end

  def test_init
    assert File.exist?(ROOT)
    assert File.exist?(ROOT + '/database.yml')
  end

  # def test_start
  #   flunk "not yet"
  # end

  # def test_stop
  #   flunk "can't stop the funk"
  # end

  def test_migrate
    suppress_out { Harker.launch('sample_rails', [ROOT, 'migrate']) }
    assert_equal(['id', 'tidings', 'updated_at', 'created_at'].sort,
                 Hark.columns.map{ |c| c.name }.sort)
  end

  private
  def suppress_out
    $stdout = StringIO.new
    yield
  ensure
    $stdout = STDOUT
  end
end

MiniTest::Unit.autorun
