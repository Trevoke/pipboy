require 'fileutils'

module Pipboy
  class Monitor
    def initialize args={}
      @configdir = args.fetch(:configdir, "~/config")
    end

    def watch file
      raise(FileDoesNotExist, "#{file} does not exist") unless File.exists?(file)
      FileUtils.mv file, @configdir
      File.symlink "#@configdir/#{file}", file
    end

    def files
      Dir.entries @configdir
    end
  end
end
