require 'git'

module Pipboy
  class EffKey
    def initialize configdir
      @g = ::Git.open configdir
    rescue ArgumentError
      @g = ::Git.init configdir
    end

    def save *files
      files = files.map { |x| File.basename x }
      @g.add files
      @g.commit "Added #{files.join(', ')}"
    end
  end
end
