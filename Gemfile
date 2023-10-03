source 'https://rubygems.org'

ruby '2.7.7'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.6'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.4.1'

gem 'multi_json'

# Use the puma server
gem 'puma', '~> 5.6.4'
# Memcache
gem 'dalli'

gem 'uglifier'
gem 'rack-cors', require: 'rack/cors'

gem 'auth0'
gem 'knock', '~> 2.0'
gem 'algoliasearch-rails'
gem 'rails-controller-testing'

gem 'responders'
gem 'roar-rails'
gem 'chargebee'

# This is needed to load on heroku, should be fixed later.

# Analytics & Reporting
gem 'sentry-raven'

# Caching
gem 'actionpack-action_caching'

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
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.6.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :production do
  gem 'skylight'
  gem 'le'
end
