require 'fileutils'

module Pipboy
  class Monitor
    include FileComparisons

    def initialize args={}
      @configdir = args.fetch(:configdir, "~/config")
    end

    def watch file
      file_exists = file_exists? file
      raise(FileDoesNotExist) unless file_exists
      Inventory.new(db: "#@configdir/pipboy.yml").store file
      FileUtils.mv file, @configdir
      File.symlink "#@configdir/#{file}", file
    end

    def files
      Dir.entries @configdir
    end

    def watched? file
      files.include? file
    end
  end
end
