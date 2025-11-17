# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pipboy/version'

Gem::Specification.new do |gem|
  gem.name          = "pipboy"
  gem.version       = Pipboy::VERSION
  gem.authors       = ["Aldric Giacomoni"]
  gem.email         = ["trevoke@gmail.com"]
  gem.description   = %q{Manage your *nix config files}
  gem.summary       = %q{Aren't you tired of not being able to back up your config files, regardless or where they are? Your entire bin directory maybe? Your global gemset? Pipboy lets you do all that. Health monitor not included.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 3.0.0'

  gem.add_runtime_dependency 'git', '~> 2.3'
  gem.add_runtime_dependency 'thor', '~> 1.3'

  gem.add_development_dependency 'rspec', '~> 3.13'
  gem.add_development_dependency 'rspec-its', '~> 1.3'
  gem.add_development_dependency 'cucumber'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rdoc'
end
