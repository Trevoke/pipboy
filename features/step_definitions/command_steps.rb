When /^I type "pipboy watch .bashrc"$/ do 
  Pipboy::Monitor.watch '.bashrc' 
end

