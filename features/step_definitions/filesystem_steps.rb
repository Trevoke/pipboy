require 'fileutils'
require 'tempfile'
require 'tmpdir'

Given /^an empty home directory$/ do
  @homedir = Dir.mktmpdir
end

And /^an empty config directory$/ do
  @configdir = Dir.mktmpdir
  Pipboy.config do |c|
    c.config_dir = @configdir
  end
end

Given /^a file named "(.*?)" in the home directory$/ do |file|
  filepath = File.expand_path File.join(@homedir, file)
  FileUtils.touch filepath
end

And /^"(.*?)" in the home directory should be a "(.*?)"$/ do |file, filetype|
  filepath = File.expand_path File.join(@homedir, file)
  case filetype
    when 'symlink'
      File.symlink?(filepath).should be_truthy
    else
      raise ArgumentError
  end
end

Then /^"(.*?)" in the home directory should point to the file in the config directory$/ do |file|
  destpath = File.join(@configdir, file)
  symlink_destination = File.readlink(File.join(@homedir, file))
  symlink_destination.should eq destpath
end

After do
  FileUtils.rmtree @homedir
  FileUtils.rmtree @configdir
end

Then /^there should be "(.*?)" files? in the config directory$/ do |number|
  count = number.to_i
  files_in_config = Dir.entries(@configdir)
  # Magic number alert! This includes ., .., the pipboy.yml file, and .git
  files_in_config.size.should eq count + 4
end
