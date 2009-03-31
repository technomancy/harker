require 'harker'
require 'fileutils'
require 'erb'

module Harker
  # Turn an existing Rails app into a gem.
  def self.gemify(rails_root)
    @project_name = File.basename(rails_root)
    if File.exist?(rails_root + "/bin/#{@project_name}") or
        File.exist?(rails_root + "/lib/#{@project_name}.rb")
      abort "Can't write gem files without overwriting existing ones.
Try manually gemifying."
    end

    File.open(File.join(rails_root, '/Rakefile'), 'a') do |fp|
      fp.puts template('hoe')
      puts "Added hoe block to Rakefile."
    end

    FileUtils.mkdir_p(File.join(rails_root, '/bin'))
    File.open(File.join(rails_root, "/bin/#{@project_name}"), 'w') do |fp|
      fp.puts template('bin')
      puts "Wrote bin launcher."
    end

    File.open(File.join(rails_root, "/lib/#{@project_name}.rb"), 'w') do |fp|
      fp.puts template('lib')
      puts "Wrote lib file."
    end

    # Submitted a patch to hoe to make it ignore log files by default,
    # but folks should still give it a once-over manually anyway.
    system "cd #{rails_root}; touch Manifest.txt; rake check_manifest | patch"
    puts "Wrote Manifest.txt."
    puts "Ensure the manifest doesn't contain files you don't want in the gem."
    puts "Then try running rake install_gem."
  end

  def self.template(name)
    template_path = File.join File.dirname(__FILE__), 'templates', "#{name}.erb"
    ERB.new(File.read(template_path)).result(binding)
  end
end
