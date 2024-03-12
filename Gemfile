source 'https://rubygems.org'

gem 'rails', '~> 6.0.5'
gem 'pg', '~> 1.4.1'

gem 'multi_json'

# Use the puma server
gem 'puma', '~> 5.6.4'

gem 'rack-cors', require: 'rack/cors'

gem 'auth0'
gem 'knock', '~> 2.0'
gem 'algoliasearch-rails'

gem 'responders'
gem 'roar-rails'
gem 'chargebee'

# Analytics & Reporting
gem 'sentry-raven'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 11.0'
  gem 'pry', '~> 0.13.1'
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
