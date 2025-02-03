Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    {
      request_id: RequestStore.store[:request_id],
      user_id:    RequestStore.store[:current_user_id],
      params:     event.payload[:params]&.except('controller', 'action', 'format')
    }.compact
  end
end
