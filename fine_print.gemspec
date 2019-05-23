$:.push File.expand_path('../lib', __FILE__)

require 'fine_print/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'fine_print'
  s.version     = FinePrint::VERSION
  s.authors     = ['JP Slavinsky', 'Dante Soares']
  s.email       = ['dms3@rice.edu']
  s.homepage    = 'http://github.com/lml/fine_print'
  s.license     = 'MIT'
  s.summary     = 'Manages site agreements with versioning.'
  s.description = 'FinePrint allows site admins to easily create, update and ask users to sign site agreements, keeping a record of when users signed a certain version of each agreement.'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'action_interceptor'
  s.add_dependency 'responders'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'coveralls'
end
