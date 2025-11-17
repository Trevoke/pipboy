module Pipboy
  class Configuration
    attr_reader :config_dir

    def initialize
      @config_dir = default_config_dir
    end

    def config_dir= new_directory_name
      @config_dir = new_directory_name
      Dir.mkdir @config_dir unless File.directory?(@config_dir)
    end

    private

    def default_config_dir
      File.join(Dir.home, '.config', 'pipboy')
    end
  end
end