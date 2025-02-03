max_threads = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
min_threads = ENV.fetch('RAILS_MIN_THREADS', max_threads).to_i
threads min_threads, max_threads

worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

port        ENV.fetch('PORT', 3000)
environment ENV.fetch('RAILS_ENV', 'development')

# Single process in development — cluster mode + preload_app breaks forked Redis/DB connections.
default_workers = ENV.fetch('RAILS_ENV', 'development') == 'production' ? 2 : 0
workers ENV.fetch('WEB_CONCURRENCY', default_workers).to_i

preload_app! if ENV.fetch('WEB_CONCURRENCY', default_workers).to_i.positive?

plugin :tmp_restart
