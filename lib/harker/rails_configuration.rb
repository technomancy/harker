# TODO: not sure if my Rails patches cover tmp/sessions or tmp/sockets
# TODO: submit patch upstream

class Rails::Configuration
  attr_accessor :tmp_dir

  def default_tmp_dir
    File.join(root_path, 'tmp')
  end

  def default_cache_store
    if File.exist? File.join(default_tmp_dir, 'cache')
      [ :file_store, File.join(default_tmp_dir, 'cache') ]
    else
      :memory_store
    end
  end
end

class Rails::Initializer
  def self.run(command = :process, configuration = Configuration.new)
    yield configuration if block_given?
    Harker.configure(configuration)
    initializer = new configuration
    initializer.send(command)
    initializer
  end
end
