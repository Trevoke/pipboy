require 'fileutils'
require 'tempfile'

Given /^a file named "(.*?)" in my home directory$/ do |file|
  FileUtils.touch '.bashrc'
end
