require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GuesstimateApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Autoload and eager-load lib/ (excluding rake tasks), replacing the old
    # `autoload_paths << lib` + `enable_dependency_loading` (removed in Rails 7).
    config.autoload_lib(ignore: %w[tasks])
  end
end
