class HealthController < ActionController::API
  def liveness
    render json: { status: 'ok', time: Time.current.iso8601 }
  end

  def readiness
    checks = { db: db_ok?, redis: redis_ok? }
    status = checks.values.all? ? :ok : :service_unavailable
    render json: { status: status == :ok ? 'ready' : 'degraded', checks: checks }, status: status
  end

  private

  def db_ok?
    ActiveRecord::Base.connection.execute('SELECT 1') && true
  rescue StandardError
    false
  end

  def redis_ok?
    REDIS.with { |r| r.ping == 'PONG' }
  rescue StandardError
    false
  end
end
