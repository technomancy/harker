require 'harker'
require 'fileutils'

module Harker
  def self.gemify(rails_root)
    project_name = File.basename(rails_root)

    if File.writable?(rails_root + "/bin/#{project_name}") or
        File.writable?(rails_root + "/lib/#{project_name}.rb")
      abort "Can't write gem files without overwriting existing ones.
Try manually gemifying."
    end

    # TODO: Hoe's test tasks stomp on Rails'
    # TODO: can we specify the version better?
    hoe = "Hoe.new('#{project_name}', '1.0.0') do |p|
  p.extra_deps << ['rails', '~> 2.3.2']
  p.extra_deps << ['harker', '~> #{Harker::VERSION}']
  p.developer('Your Name', 'you@example.com') # FIXME!
end"

    bin = "#!/usr/bin/env ruby
require 'rubygems'
require 'harker'

Harker.launch(File.basename($0), ARGV)"

    lib = "# Allow rubygems to load this app
require File.dirname(__FILE__) + '/../config/environment'"

    File.open(rails_root + '/Rakefile', 'a') { |fp| fp.puts hoe }
    puts "Added hoe block to Rakefile."
    FileUtils.mkdir_p(rails_root + '/bin')
    File.open(rails_root + "/bin/#{project_name}", 'w') {|fp| fp.puts bin }
    puts "Wrote bin launcher."
    File.open(rails_root + "/lib/#{project_name}.rb", 'w') {|fp| fp.puts lib }
    puts "Wrote lib file."
    system "cd #{rails_root}; rake check_manifest | patch"
    puts "Wrote manifest."

    puts "Done! Try running rake install_gem."
  end
end
