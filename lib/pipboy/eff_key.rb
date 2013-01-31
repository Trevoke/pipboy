module Pipboy
  class EffKey
    def initialize configdir
      @g = Git.open configdir
    rescue ArgumentError
      @g = Git.init configdir
    end

    def save file
      @g.add File.basename(file)
      @g.commit "Added #{File.basename file}"
    end
  end
end
