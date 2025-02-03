require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort('Rails is in production!') if Rails.env.production?
require 'rspec/rails'
require 'database_cleaner/active_record'
require 'webmock/rspec'
require 'mock_redis'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join('spec/fixtures').to_s]
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include ActiveJob::TestHelper
  config.include AuthHelpers, type: :request

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end
  config.around do |example|
    DatabaseCleaner.cleaning { example.run }
  end

  # Replace global Redis pool with an in-memory mock for the test suite.
  fake = MockRedis.new

  config.before(:each) do |example|
    if example.metadata[:real_redis]
      pool = ConnectionPool.new(size: 1) do
        Redis.new(
          url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/15')
        )
      end

      stub_const('REDIS', pool)

      REDIS.with(&:flushdb)
    else
      pool = ConnectionPool.new(size: 1) { fake }
      stub_const('REDIS', pool)

      fake.flushdb
    end
  end

  config.after(:each, :real_redis) do
    REDIS.with(&:flushdb)
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
