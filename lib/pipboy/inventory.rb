require 'yaml'

module Pipboy
  class Inventory
    def list file='pipboy.yml', output=$stdout
      YAML.load_file(file).each do |key, value|
        output.puts "#{key} => #{value}"
      end
    end

    def retrieve file, saved_file='pipboy.yml'
      x = YAML.load_file(saved_file)
      return x[file]
    end
  end
end
