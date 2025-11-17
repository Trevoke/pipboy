require 'fileutils'

module Pipboy
  class Restore
    def initialize
      @config_dir = Pipboy.configuration.config_dir
      @inventory = Inventory.new(db: "#{@config_dir}/pipboy.yml")
    end

    def restore(file)
      expanded_path = File.expand_path(file)
      basename = File.basename(file)

      # Check if file is being watched (using full path now)
      original_location = @inventory.retrieve(expanded_path)
      raise FileNotWatched, "#{basename} is not being watched" unless original_location

      # Full paths
      backed_up_file = File.join(@config_dir, basename)
      original_path = File.join(original_location, basename)

      # Check if backed up file exists
      raise FileDoesNotExist, "Backed up file #{backed_up_file} does not exist" unless File.exist?(backed_up_file)

      # Remove symlink if it exists
      if File.symlink?(original_path)
        File.unlink(original_path)
      elsif File.exist?(original_path)
        raise FileExistsError, "#{original_path} exists but is not a symlink. Cannot restore safely."
      end

      # Move file back to original location
      FileUtils.mv(backed_up_file, original_path)

      # Remove from inventory
      remove_from_inventory(expanded_path)

      # Commit to git
      eff_key = EffKey.new(@config_dir)
      eff_key.save('pipboy.yml')

      original_path
    end

    private

    def remove_from_inventory(full_path)
      files = @inventory.files
      files.delete(full_path)
      File.open("#{@config_dir}/pipboy.yml", 'w') do |yaml|
        yaml << files.to_yaml
      end
    end
  end
end
