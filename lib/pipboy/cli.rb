require 'thor'
require_relative '../pipboy'

module Pipboy
  class CLI < Thor

    desc "watch FILE", "Watch a configuration file and back it up"
    long_desc <<-LONGDESC
      Watch a configuration file by moving it to the Pipboy config directory
      and creating a symlink at the original location. The file is tracked in
      Git for version control.

      Example:
        $ pipboy watch ~/.bashrc
    LONGDESC
    option :config_dir, type: :string, desc: "Override default config directory"
    def watch(file)
      setup_config
      monitor = Pipboy::Monitor.new

      begin
        monitor.watch(File.expand_path(file))
        say "✓ Now watching #{file}", :green
      rescue Pipboy::FileDoesNotExist
        say "✗ Error: #{file} does not exist", :red
        exit 1
      rescue => e
        say "✗ Error: #{e.message}", :red
        exit 1
      end
    end

    desc "restore FILE", "Restore a backed-up file to its original location"
    long_desc <<-LONGDESC
      Restore a previously watched file by removing the symlink and moving
      the actual file back to its original location.

      Example:
        $ pipboy restore ~/.bashrc
    LONGDESC
    option :config_dir, type: :string, desc: "Override default config directory"
    def restore(file)
      setup_config
      restore_manager = Pipboy::Restore.new

      begin
        restored_path = restore_manager.restore(File.expand_path(file))
        say "✓ Restored #{file} to #{restored_path}", :green
      rescue Pipboy::FileNotWatched => e
        say "✗ Error: #{e.message}", :red
        exit 1
      rescue Pipboy::FileDoesNotExist => e
        say "✗ Error: #{e.message}", :red
        exit 1
      rescue Pipboy::FileExistsError => e
        say "✗ Error: #{e.message}", :red
        exit 1
      rescue => e
        say "✗ Error: #{e.message}", :red
        exit 1
      end
    end

    desc "list", "List all watched files"
    long_desc <<-LONGDESC
      Display a list of all configuration files currently being watched
      by Pipboy, along with their original locations.
    LONGDESC
    option :config_dir, type: :string, desc: "Override default config directory"
    def list
      setup_config
      inventory = Pipboy::Inventory.new(db: "#{Pipboy.configuration.config_dir}/pipboy.yml")
      files = inventory.list

      if files.empty?
        say "No files are currently being watched.", :yellow
      else
        say "Watched files:", :green
        files.each do |file_info|
          say "  #{file_info}"
        end
      end
    rescue => e
      say "✗ Error: #{e.message}", :red
      exit 1
    end

    desc "status", "Show Pipboy status and configuration"
    long_desc <<-LONGDESC
      Display information about the current Pipboy configuration,
      including the config directory location and Git repository status.
    LONGDESC
    option :config_dir, type: :string, desc: "Override default config directory"
    def status
      setup_config
      config_dir = Pipboy.configuration.config_dir

      say "Pipboy Status", :bold
      say "=" * 50
      say "Config directory: #{config_dir}"
      say "Directory exists: #{File.directory?(config_dir) ? 'Yes' : 'No'}"

      if File.directory?(config_dir)
        git_dir = File.join(config_dir, '.git')
        say "Git initialized: #{File.directory?(git_dir) ? 'Yes' : 'No'}"

        inventory_file = File.join(config_dir, 'pipboy.yml')
        if File.exist?(inventory_file)
          inventory = Pipboy::Inventory.new(db: inventory_file)
          file_count = inventory.files.size
          say "Files watched: #{file_count}"
        else
          say "Files watched: 0"
        end
      end
    end

    desc "init", "Initialize Pipboy configuration directory"
    long_desc <<-LONGDESC
      Create the Pipboy configuration directory and initialize a Git
      repository for tracking changes.

      Example:
        $ pipboy init
    LONGDESC
    option :config_dir, type: :string, desc: "Override default config directory"
    def init
      setup_config
      config_dir = Pipboy.configuration.config_dir

      if File.directory?(config_dir)
        say "✓ Config directory already exists at #{config_dir}", :yellow
      else
        Dir.mkdir config_dir
        say "✓ Created config directory at #{config_dir}", :green
      end

      git_dir = File.join(config_dir, '.git')
      if File.directory?(git_dir)
        say "✓ Git repository already initialized", :yellow
      else
        Pipboy::EffKey.new(config_dir)
        say "✓ Initialized Git repository", :green
      end

      say "\nPipboy is ready to use! Try:", :green
      say "  pipboy watch ~/.bashrc"
    end

    desc "version", "Show Pipboy version"
    def version
      say "Pipboy version #{Pipboy::VERSION}"
    end

    private

    def setup_config
      if options[:config_dir]
        Pipboy.config do |c|
          c.config_dir = File.expand_path(options[:config_dir])
        end
      end
    end
  end
end
