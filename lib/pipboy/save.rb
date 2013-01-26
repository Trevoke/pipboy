require 'yaml'

module Pipboy
  class Save

    def initialize args
      @db = args.fetch :db
    end

    def call(object)
      File.open(@db, 'w') do |f|
        f << object.to_yaml
      end
    end

    def values
      YAML.load_file @db
    end

  end
end
