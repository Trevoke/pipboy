require 'fileutils'

module Pipboy
  class Monitor
    include FileComparisons

    def initialize args={}
      @configdir = args.fetch(:configdir, "~/config")
    end

    def watch file
      Dir.mkdir(@configdir) unless File.directory? @configdir
      raise(FileDoesNotExist) unless file_exists?(file)
      Inventory.new(db: "#@configdir/pipboy.yml").store file
      create_symlink_for file
      EffKey.new(@configdir).save file
    end

    def files
      Dir.entries(@configdir)
    end

    def watched? file
      files.include? file
    end

    private

    def create_symlink_for file
      FileUtils.mv file, @configdir
      File.symlink "#@configdir/#{file}", file
    end
  end
end
