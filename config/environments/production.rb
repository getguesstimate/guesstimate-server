BASE_URL = 'https://www.getguesstimate.com/'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins /\Ahttps:\/\/[a-z]+\.getguesstimate.com\z/,
              /\Ahttp:\/\/([^w]|w[^w])[a-z]*\.getguesstimate.com\z/,
              # This seems relatively safe: auth cookie is stored on the real frontend, and get requests won't change anything.
              # (By the same logic, we could just disable CORS entirely.)
              /\Ahttps:\/\/guesstimate-app-.*-quantified-uncertainty.vercel.app\z/
      resource '*', headers: :any, methods: [:get, :post, :options, :delete, :put, :update, :patch]
    end

    # convenient for local dev and not very dangerous
    allow do
      origins 'localhost:3000'
      resource '*', headers: :any, methods: [:get, :options]
    end
  end
end
