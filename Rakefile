require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format progress"
end

