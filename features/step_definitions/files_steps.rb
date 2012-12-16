require 'fileutils'
require 'tempfile'

Given /^a file named "(.*?)" in my home directory$/ do |file|
  @file = Tempfile.new file, @homedir
end

Then /^"\.bashrc" should be in the config directory$/ do
  Dir.entries(@configdir).should include(File.basename(@file))
end

Given /^a symlink to "(.*?)" in the config directory$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
