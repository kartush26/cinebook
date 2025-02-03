SecureHeaders::Configuration.default do |config|
  config.hsts = "max-age=#{1.year.to_i}; includeSubDomains; preload"
  config.x_frame_options       = 'DENY'
  config.x_content_type_options = 'nosniff'
  config.x_xss_protection      = '1; mode=block'
  config.referrer_policy       = 'strict-origin-when-cross-origin'
  config.csp = SecureHeaders::OPT_OUT # API only; CSP enforced at the frontend host
end
