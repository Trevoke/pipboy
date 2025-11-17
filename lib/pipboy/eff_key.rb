require 'git'

module Pipboy
  class EffKey
    def initialize configdir
      @g = ::Git.open configdir
    rescue ArgumentError
      @g = ::Git.init configdir
      configure_git
    end

    def configure_git
      # Disable commit signing (can be overridden in user config)
      @g.config('commit.gpgsign', 'false') rescue nil
      # Set default user if not configured
      @g.config('user.name', 'Pipboy') rescue nil
      @g.config('user.email', 'pipboy@localhost') rescue nil
    end

    def save *files
      files = files.map { |x| File.basename x }
      @g.add files
      @g.commit "Added #{files.join(', ')}"
    end
  end
end
