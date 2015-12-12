require "auth0"
require 'pry'

auth0 = Auth0Client.new(
  :api_version => 2,
  :token => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJUWnBQRXp5eWpQbTN2VmdSdU9yQjJTakRTVnhFdnJiSCIsInNjb3BlcyI6eyJ1c2VycyI6eyJhY3Rpb25zIjpbInJlYWQiXX19LCJpYXQiOjE0NDk4OTM2OTMsImp0aSI6IjJhNjJiNDJmY2IyODE5ZmJhN2EzNWE1NDNkYmIyMDZiIn0.Kcq6ipqAk63JujvXuPnAnMwfxZ2C8DMCk-JWehGfSEc",
  :domain => "guesstimate-development.auth0.com"
)

class Auth0Sync
  def initialize(auth0)
    @auth0 = auth0
    @auth0_users = @auth0.get_users
    if !@auth0_users || @auth0_users.empty?
      Rails.logger.error "Auth0 did not return users when attempting to Sync!"
    end
  end

  def run
    new_users = new_auth0_users
    new_users.each do |auth0_user|
      attributes = {
          name: auth0_user['name'],
          picture: auth0_user['picture'],
          auth0_id: auth0_user['user_id'],
          username: auth0_user['nickname']
      }
      User.create(attributes)
      puts "Created user with attributes #{attributes}"
      Rails.logger.info "Created user with attributes #{attributes}"
    end
  end

  def new_auth0_users
    @auth0_users.select{|e| !User.exists?(auth0_id: e["user_id"])}
  end
end

Auth0Sync.new(auth0).run
