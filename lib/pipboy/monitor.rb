require 'fileutils'
require_relative 'file_comparisons'

module Pipboy
  class Monitor
    include FileComparisons

    def initialize args={}
      @configdir = args.fetch(:configdir, "~/config")
    end

    def watch file
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
      path = File.expand_path file
      Dir.mkdir(@configdir) unless File.directory? @configdir
      FileUtils.mv path, @configdir
      File.symlink "#@configdir/#{file}", path
    end
  end
end
