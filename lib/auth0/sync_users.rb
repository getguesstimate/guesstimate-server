require "auth0"

auth0 = Auth0Client.new(
  :api_version => 2,
  :token => "YOUR JWT HERE",
  :domain => "<YOUR ACCOUNT>.auth0.com"
)

puts auth0.get_users
