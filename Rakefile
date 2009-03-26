# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/harker.rb'

Hoe.new('harker', Harker::VERSION) do |p|
  p.readme_file = 'README.rdoc'
  p.summary = "Concourse is a tool to make planning gatherings easy."
  p.extra_deps << ["rails", "~> 2.3.2"]
  p.extra_dev_deps << ["minitest", "~> 1.3.1"]
  p.extra_dev_deps << ["sqlite3-ruby", "~> 1.2.4"]
  p.developer('Phil Hagelberg', 'technomancy@gmail.com')
end

# vim: syntax=Ruby
