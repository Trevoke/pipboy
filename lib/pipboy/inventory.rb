require 'yaml'

module Pipboy
  class Inventory
    def initialize args
      @db = args.fetch :db
    end
    def list
      output = []
      YAML.load_file(@db).each do |key, value|
        output << "#{key} => #{value}"
      end
      output
    end

    def retrieve file
      x = YAML.load_file(@db)
      return x[file]
    end
  end
end
