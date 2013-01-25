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
      @files ||= YAML.load_file @db
    end

    def retrieve file
      files[file]
    end
  end
end
