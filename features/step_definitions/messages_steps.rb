Then /^I should get a message "(.*?)"$/ do |arg1|
    @pipboy.output.should eq arg1
end
