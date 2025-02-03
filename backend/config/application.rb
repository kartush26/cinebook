require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

module Cinebook
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true

    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec, fixtures: false
      g.factory_bot dir: 'spec/factories'
    end

    config.active_job.queue_adapter = :sidekiq

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use Rack::Attack
    config.middleware.use RequestStore::Middleware

    config.action_cable.mount_path = '/cable'
    config.action_cable.allowed_request_origins = [ENV.fetch('FRONTEND_URL', 'http://localhost:5173')]
  end
end
