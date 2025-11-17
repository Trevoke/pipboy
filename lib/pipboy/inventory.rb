require 'yaml'
require 'fileutils'

module Pipboy
  class Inventory
    def initialize args
      @db = args.fetch :db
    end

    def list
      output = []
      files.each do |path, metadata|
        if metadata.is_a?(Hash)
          output << "#{metadata['basename']} => #{metadata['dirname']}"
        else
          # Legacy format compatibility
          output << "#{path} => #{metadata}"
        end
      end
      output
    end

    def files
      # Always read from disk to ensure we have the latest data
      read_with_lock
    end

    def retrieve file
      expanded_path = File.expand_path(file)
      metadata = files[expanded_path]
      return nil unless metadata

      # Return dirname for backward compatibility
      metadata.is_a?(Hash) ? metadata['dirname'] : metadata
    end

    def store file
      expanded_path = File.expand_path(file)
      new_entry = {
        'basename' => File.basename(file),
        'dirname' => File.dirname(expanded_path)
      }

      write_with_lock do |current_files|
        current_files[expanded_path] = new_entry
        current_files
      end
    end

    private

    def read_with_lock
      return {} unless File.exist?(@db)

      File.open(@db, 'r') do |file|
        file.flock(File::LOCK_SH)
        begin
          YAML.safe_load_file(@db, permitted_classes: [Symbol], aliases: true) || {}
        ensure
          file.flock(File::LOCK_UN)
        end
      end
    end

    def write_with_lock
      # Ensure parent directory exists
      FileUtils.mkdir_p(File.dirname(@db))

      # Create file if it doesn't exist
      FileUtils.touch(@db) unless File.exist?(@db)

      File.open(@db, File::RDWR) do |file|
        file.flock(File::LOCK_EX)
        begin
          # Read current contents
          current_files = if file.size > 0
            file.rewind
            YAML.safe_load(file.read, permitted_classes: [Symbol], aliases: true) || {}
          else
            {}
          end

          # Let the block modify the files
          updated_files = yield(current_files)

          # Write back
          file.rewind
          file.truncate(0)
          file.write(updated_files.to_yaml)
          file.flush
        ensure
          file.flock(File::LOCK_UN)
        end
      end
    end
  end
end
