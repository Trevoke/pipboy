module Pipboy
  class Configuration
    attr_reader :config_dir

    def initialize
      #TODO set up default to ~config - will lead to testing issues
      #I don't want to do ugly mocking. Cabinet, where art thou..
    end

    def config_dir= new_directory_name
      @config_dir = new_directory_name
      Dir.mkdir @config_dir unless File.directory?(@config_dir)
    end
  end
end