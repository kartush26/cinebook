require 'sidekiq'
require 'sidekiq-cron'

redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  schedule_file = Rails.root.join('config/sidekiq.yml')
  if File.exist?(schedule_file)
    yaml = YAML.load_file(schedule_file)
    Sidekiq::Cron::Job.load_from_hash(yaml[:scheduler][:schedule]) if yaml.dig(:scheduler, :schedule)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
