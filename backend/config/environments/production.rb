require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, { url: ENV.fetch('REDIS_URL') }

  config.log_level = ENV.fetch('LOG_LEVEL', 'info').to_sym
  config.log_tags  = [:request_id]
  config.logger    = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

  config.active_record.dump_schema_after_migration = false

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:        ENV['SMTP_HOST'],
    port:           ENV.fetch('SMTP_PORT', 587).to_i,
    user_name:      ENV['SMTP_USER'],
    password:       ENV['SMTP_PASSWORD'],
    authentication: :plain,
    enable_starttls_auto: true
  }

  config.active_storage.service = :amazon

  config.force_ssl = true
  config.hosts << ENV.fetch('APP_HOST', 'api.cinebook.example')
end
