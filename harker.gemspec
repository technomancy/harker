Gem::Specification.new do |s|
  s.name = %q{harker}
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Phil Hagelberg"]
  s.date = %q{2009-03-30}
  s.default_executable = %q{harker}
  s.description = %q{Harker means Rails deployments via RubyGems--because a package manager is a terrible thing to waste.}
  s.email = ["technomancy@gmail.com"]
  s.executables = ["harker"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "bin/harker", "lib/harker.rb", "lib/harker/gemify.rb", "lib/harker/rails_configuration.rb", "lib/harker/server.rb", "lib/harker/templates/bin.erb", "lib/harker/templates/hoe.erb", "lib/harker/templates/lib.erb", "test/sample/Manifest.txt", "test/sample/README.rdoc", "test/sample/Rakefile", "test/sample/app/controllers/application_controller.rb", "test/sample/app/controllers/harks_controller.rb", "test/sample/app/helpers/application_helper.rb", "test/sample/app/helpers/harks_helper.rb", "test/sample/app/models/hark.rb", "test/sample/bin/sample_rails", "test/sample/config/boot.rb", "test/sample/config/database.yml", "test/sample/config/environment.rb", "test/sample/config/environments/development.rb", "test/sample/config/environments/production.rb", "test/sample/config/environments/test.rb", "test/sample/config/initializers/backtrace_silencers.rb", "test/sample/config/initializers/inflections.rb", "test/sample/config/initializers/mime_types.rb", "test/sample/config/initializers/new_rails_defaults.rb", "test/sample/config/initializers/session_store.rb", "test/sample/config/locales/en.yml", "test/sample/config/routes.rb", "test/sample/db/migrate/20090326050232_create_harks.rb", "test/sample/lib/sample_rails.rb", "test/sample/public/404.html", "test/sample/public/422.html", "test/sample/public/500.html", "test/sample/public/favicon.ico", "test/sample/public/images/rails.png", "test/sample/public/index.html", "test/sample/public/javascripts/application.js", "test/sample/public/javascripts/controls.js", "test/sample/public/javascripts/dragdrop.js", "test/sample/public/javascripts/effects.js", "test/sample/public/javascripts/prototype.js", "test/sample/public/robots.txt", "test/sample/script/about", "test/sample/script/console", "test/sample/script/dbconsole", "test/sample/script/destroy", "test/sample/script/generate", "test/sample/script/performance/benchmarker", "test/sample/script/performance/profiler", "test/sample/script/plugin", "test/sample/script/runner", "test/sample/script/server", "test/sample/test/fixtures/harks.yml", "test/sample/test/functional/harks_controller_test.rb", "test/sample/test/performance/browsing_test.rb", "test/sample/test/test_helper.rb", "test/sample/test/unit/hark_test.rb", "test/sample/test/unit/helpers/harks_helper_test.rb", "test/test_gemify.sh", "test/test_harker.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/technomancy/harker}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{harker}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Concourse is a tool to make planning gatherings easy.}
  s.test_files = ["test/sample/test/test_helper.rb", "test/test_harker.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 2.3.2"])
      s.add_development_dependency(%q<minitest>, ["~> 1.3.1"])
      s.add_development_dependency(%q<sqlite3-ruby>, ["~> 1.2.4"])
      s.add_development_dependency(%q<hoe>, [">= 1.11.0"])
    else
      s.add_dependency(%q<rails>, ["~> 2.3.2"])
      s.add_dependency(%q<minitest>, ["~> 1.3.1"])
      s.add_dependency(%q<sqlite3-ruby>, ["~> 1.2.4"])
      s.add_dependency(%q<hoe>, [">= 1.11.0"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 2.3.2"])
    s.add_dependency(%q<minitest>, ["~> 1.3.1"])
    s.add_dependency(%q<sqlite3-ruby>, ["~> 1.2.4"])
    s.add_dependency(%q<hoe>, [">= 1.11.0"])
  end
end
