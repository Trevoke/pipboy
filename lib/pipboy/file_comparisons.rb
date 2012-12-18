module Pipboy
  module FileComparisons

    def file_exists? file, output=$stdout
      return true if File.exists? file
      output.puts "#{file} does not exist."
      false
    end

  end
end
