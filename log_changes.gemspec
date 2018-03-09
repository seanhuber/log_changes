$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'log_changes/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = 'log_changes'
  s.version       = LogChanges::VERSION
  s.authors       = ['Sean Huber']
  s.email         = ['seanhuber@seanhuber.com']
  s.homepage      = 'https://github.com/seanhuber/log_changes'
  s.summary       = 'Writes changes to ActiveRecord records to dedicated logfiles'
  s.license       = 'MIT'
  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '>= 4.1'
  s.add_dependency 'sr_log', '~> 1.0'

  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails', '~> 3.5'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'coveralls', '~> 0.8'
end
