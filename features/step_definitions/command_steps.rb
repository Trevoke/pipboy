When /^I monitor "(.*?)"$/ do |file|
  filepath = File.expand_path File.join(@homedir, file)
  @monitor = Pipboy::Monitor.new
  @monitor.watch filepath
end

