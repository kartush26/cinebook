class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/2'))

  throttle('req/ip', limit: 300, period: 5.minutes) { |req| req.ip unless req.path.start_with?('/cable') }
  throttle('auth/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/v1/auth') && req.post?
  end

  blocklist('block-suspicious-ua') do |req|
    req.user_agent.to_s.match?(/sqlmap|nikto|nessus/i)
  end

  self.throttled_responder = lambda do |_req|
    [429, { 'Content-Type' => 'application/json' }, [{ error: 'Rate limit exceeded' }.to_json]]
  end
end
