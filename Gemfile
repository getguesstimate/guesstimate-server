source 'https://rubygems.org'

gem 'rails', '>= 7.2.3.1', '< 7.3'
gem 'pg', '~> 1.5'

gem 'multi_json'

# Use the puma server (>= 7.2.1 fixes GHSA-2vqw-3mp8-cgmx / GHSA-qpgp-93vx-g8v8)
gem 'puma', '~> 7.2'

gem 'rack-cors', require: 'rack/cors'

gem 'auth0'
# JWT verification for Auth0 RS256 tokens (replaces the abandoned `knock` gem).
gem 'jwt'
gem 'algoliasearch-rails'

gem 'responders'
gem 'roar-rails'
gem 'chargebee', '~> 2.72'

# Analytics & Reporting (sentry-raven is EOL; replaced by sentry-ruby/sentry-rails)
gem 'sentry-ruby'
gem 'sentry-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 11.0'
  gem 'pry', '~> 0.14'
  gem 'pry-byebug'
  gem 'pry-rails', '~> 0.3.9'

  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :test do
  gem 'shoulda-matchers'
  gem 'rspec-collection_matchers'
  gem 'rails-controller-testing'
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
