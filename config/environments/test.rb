Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = ENV["CI"].present?

  config.public_file_server.headers = { "Cache-Control" => "public, max-age=3600" }

  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Return 404 and similar responses instead of raising, so request specs can check them.
  config.action_dispatch.show_exceptions = :rescuable

  config.action_controller.allow_forgery_protection = false

  config.active_support.deprecation = :stderr
  config.action_controller.raise_on_missing_callback_actions = true
end
