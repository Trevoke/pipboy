require 'fileutils'

module Pipboy
  class Monitor
    def self.watch file
      raise FileDoesNotExist unless File.exists?(file)
      FileUtils.mv file, "tmp/"
      File.symlink "tmp/#{file}", file
    end

    def self.files
      Dir.entries 'tmp/'
    end
  end
end
