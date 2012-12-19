require 'fileutils'
require 'tempfile'
require 'tmpdir'

Then /^"\.bashrc" in my home directory should now be a symlink$/ do
  File.symlink?(@file).should be_true
end

Given /^the home directory is clean$/ do
  @homedir = Dir.mktmpdir
end

And /^the pipboy's directory is clean$/ do
  @configdir = Dir.mktmpdir
end

Given /^a file named "(.*?)" in home$/ do |file|
  @file = Tempfile.new file, @homedir
end

Then /^"\.bashrc" should be in the config directory$/ do
  Dir.entries(@configdir).should include(File.basename(@file))
end

Given /^a symlink to "(.*?)" in the config directory$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
When /^I am in the home directory$/ do
  Dir.chdir @homedir
end