When /^I type "pipboy watch ~\/.bashrc"$/ do
  @monitor = Pipboy::Monitor.new configdir: @configdir
  @monitor.watch @file
end

