# Inspired by https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

port        ENV['PORT']     || 4000
environment ENV['RACK_ENV'] || 'development' # RACK_ENV is set to production on heroku natively.
