Then /^"\.bashrc" in my home directory should now be a symlink$/ do
  File.symlink?(@file).should be_true
end

Given /^the user's home directory is clean$/ do
  require 'tmpdir'
  @homedir = Dir.mktmpdir
end

And /^the pipboy's directory is clean$/ do
  require 'tmpdir'
  @configdir = Dir.mktmpdir
end