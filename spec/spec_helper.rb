ENV['RAILS_ENV'] ||= 'test'

require 'coveralls'
Coveralls.wear!('rails')

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rspec/rails'
require 'factory_bot_rails'
require 'faker'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'
end
