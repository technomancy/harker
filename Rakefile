# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/harker.rb'

Hoe.new('harker', Harker::VERSION) do |p|
  p.developer('Phil Hagelberg', 'technomancy@gmail.com')
  p.rubyforge_name = "seattlerb"
  p.readme_file = 'README.rdoc'
  p.summary = "Harker: Rubygems-based deployment for Rails apps."

  p.extra_deps << ["rails", "~> 2.3.2"]
  p.extra_dev_deps << ["minitest", "~> 1.3.1"]
  p.extra_dev_deps << ["sqlite3-ruby", "~> 1.2.4"]
  # recommended:
  # p.extra_dev_deps << ["mongrel", "~> 1.2.4"]
end

# vim: syntax=Ruby
