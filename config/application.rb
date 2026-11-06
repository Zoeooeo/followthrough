require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module FollowThrough
  class Application < Rails::Application
    config.load_defaults 7.2

    config.time_zone = "Eastern Time (US & Canada)"

    config.generators do |g|
      g.test_framework :rspec
      g.helper false
      g.stylesheets false
      g.system_tests nil
    end
  end
end
