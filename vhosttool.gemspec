require File.expand_path('../lib/vhosttool/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'vhosttool'
  gem.version     = VhostTool::VERSION
  gem.summary     = 'Manage apache2 vhosts on debian like systems'
  gem.description = 'Create, disable, enable delete vhosts and associated web users'

  gem.license  = 'MIT'
  gem.authors  = ['Aaron Bonner']
  gem.email    = 'ajbonner@gmail.com'
  gem.homepage = 'https://github.com/ajbonner/vhosttool.git'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rubygems-tasks'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rdoc'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'etc'

  gem.add_dependency 'awesome_print'
end
