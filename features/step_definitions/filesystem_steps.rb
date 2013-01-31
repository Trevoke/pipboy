require 'pathname'
require 'fileutils'
require 'tempfile'
require 'tmpdir'

Given /^an empty home directory$/ do
  @homedir = Dir.mktmpdir
end

And /^an empty config directory$/ do
  @configdir = Dir.mktmpdir
end

Given /^a file named "(.*?)" in the home directory$/ do |file|
  filepath = File.expand_path File.join(@homedir, file)
  @file = FileUtils.touch filepath
end

And /^"(.*?)" in the home directory should be a "(.*?)"$/ do |file, filetype|
  filepath = File.expand_path File.join(@homedir, file)
  case filetype
    when 'symlink'
      File.symlink?(filepath).should be_true
    else
      raise ArgumentError
  end
end

Then /^"(.*?)" in the home directory should point to the file in the config directory$/ do |file|
  destpath = File.expand_path File.join(@configdir, file)
  orig_dir = Dir.pwd
  Dir.chdir @configdir
  symlink_destination = Pathname.new(file).realpath.to_s
  Dir.chdir orig_dir
  symlink_destination.should match Regexp.escape(destpath)

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
