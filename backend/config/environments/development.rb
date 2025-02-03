require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true
  config.cache_store = :redis_cache_store, { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/3') }
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_storage.service = :local
  config.active_storage.url_expires_in = 1.hour

  # Needed for url_helpers to generate correct blob URLs (poster_url, banner_url)
  routes.default_url_options = { host: ENV.fetch('BACKEND_URL', 'http://localhost:3000') }
  config.action_mailer.delivery_method = :test
  config.hosts.clear
end
