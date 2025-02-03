Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('FRONTEND_URL', 'http://localhost:5173'),
            'http://127.0.0.1:5173'
    resource '*',
             headers: :any,
             expose: %w[Authorization X-Request-Id],
             methods: %i[get post put patch delete options head],
             credentials: false
  end
end
