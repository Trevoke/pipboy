Then /^there should be no untracked files in the config repository$/ do
  g = Git.open @configdir
  g.status.untracked.should be_empty
end
