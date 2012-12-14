Then /^.bashrc should now be a symlink$/ do
  File.symlink?('.bashrc').should be_true
end
