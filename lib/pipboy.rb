require_relative 'pipboy/version'
require_relative 'pipboy/errors'
require_relative 'pipboy/file_comparisons'
require_relative 'pipboy/monitor'
require_relative 'pipboy/restore'
require_relative 'pipboy/save'
require_relative 'pipboy/inventory'
require_relative 'pipboy/eff_key'
require_relative 'pipboy/configuration'

module Pipboy
  class << self
    attr_accessor :configuration

    def config
      yield configure if block_given?
    end

    def configure
      @configuration ||= Configuration.new
    end
  end
end
