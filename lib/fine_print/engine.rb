require 'action_interceptor'
require 'fine_print/action_controller/base'

module FinePrint
  class Engine < ::Rails::Engine
    isolate_namespace FinePrint

    initializer "fine_print.factories",
                after: "factory_bot.set_factory_paths" do
      FactoryBot.definition_file_paths << File.join(
        root, 'spec', 'factories', 'fine_print'
      ) if defined?(FactoryBot)
    end

    # http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
    config.generators do |g|
      g.test_framework      :rspec,        fixture: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.assets false
      g.helper false
    end

    # Load subfolders of config/locales as well
    config.i18n.load_path += \
      Dir[root.join('config', 'locales', '**', '*.{rb,yml}')]
  end
end
