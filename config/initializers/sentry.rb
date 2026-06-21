if Rails.application.secrets.sentry_dsn.present?
  Sentry.init do |config|
    config.dsn = Rails.application.secrets.sentry_dsn
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    # Send 10% of transactions for performance monitoring.
    config.traces_sample_rate = 0.1
  end
end
