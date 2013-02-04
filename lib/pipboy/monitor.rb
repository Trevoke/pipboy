require 'fileutils'
require_relative 'file_comparisons'

module Pipboy
  class Monitor
    include FileComparisons

    def config_dir
      Pipboy.configuration.config_dir
    end

    def watch file
      raise(FileDoesNotExist) unless file_exists?(file)
      create_symlink_for file
      Inventory.new(db: "#{config_dir}/pipboy.yml").store file
      EffKey.new(config_dir).save file, 'pipboy.yml'
    end

    def files
      Dir.entries(config_dir)
    end

    def watched? file
      files.include? file
    end

    private

    def create_symlink_for file
      path = File.expand_path file
      FileUtils.mv path, config_dir
      File.symlink "#{config_dir}/#{file}", path
    end
  end
end
