require 'yaml'

module Pipboy
  class Inventory
    def initialize args
      @db = args.fetch :db
    end

    def list
      output = []
      files.each do |key, value|
        output << "#{key} => #{value}"
      end
      output
    end

    def files
      @files ||= File.exist?(@db) ? YAML.load_file(@db) : {}
    end

    def retrieve file
      files[file]
    end

    def store file
      files[File.basename(file)] = File.dirname(file)
      File.open(@db, 'w') do |yaml|
        yaml << files.to_yaml
      end
    end
  end
end
