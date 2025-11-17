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
      basename = File.basename(file)
      backed_up_path = File.join(config_dir, basename)

      # Move the file
      FileUtils.mv path, config_dir

      begin
        # Try to create symlink
        File.symlink backed_up_path, path
      rescue => e
        # Rollback: move file back to original location
        FileUtils.mv backed_up_path, path
        raise e
      end
    end
  end
end
