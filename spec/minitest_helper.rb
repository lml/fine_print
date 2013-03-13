# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "minitest/autorun"
require "minitest/rails"

require "minitest/rails/capybara"

Rails.backtrace_cleaner.remove_silencers!

