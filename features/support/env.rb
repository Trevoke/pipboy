require 'cucumber'
require 'pathname'
require 'ostruct'

App = OpenStruct.new

App.root = File.join(Pathname.new(__FILE__).dirname, '..', '..')

require File.join App.root, 'lib', 'pipboy.rb'
