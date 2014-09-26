require 'action_interceptor'
require 'squeel'

module FinePrint
  class Engine < ::Rails::Engine
    isolate_namespace FinePrint

    initializer "fine_print.factories", :after => "factory_girl.set_factory_paths" do
      FactoryGirl.definition_file_paths << File.join(root, 'spec', 'factories', 'fine_print') \
        if defined?(FactoryGirl)
    end

    # http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
