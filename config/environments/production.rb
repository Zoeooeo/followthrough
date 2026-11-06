Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Heroku serves the app over HTTPS and has no separate web server for static files.
  config.public_file_server.enabled = true
  config.force_ssl = true

  # Heroku collects logs from STDOUT.
  config.logger = ActiveSupport::TaggedLogging.new(
    ActiveSupport::Logger.new($stdout).tap { |logger| logger.formatter = ::Logger::Formatter.new }
  )
  config.log_tags = [:request_id]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false

  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [:id]
end
