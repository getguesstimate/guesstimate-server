require "auth0"

class Authentor
  def initialize
    @auth0 = Auth0Client.new(
      :api_version => 2,
      :token => Rails.application.secrets.auth0_api_token,
      :domain => Rails.application.secrets.auth0_api_domain
    )

    @auth0_users = @auth0.get_users({per_page: 100})
    if !@auth0_users || @auth0_users.empty?
      Rails.logger.error "Auth0 did not return users when attempting to Sync!"
    end
  end

  def run
    new_users = new_auth0_users
    new_users.each do |auth0_user|
      attributes = {
          name: auth0_user['nickname'],
          picture: auth0_user['picture'],
          auth0_id: auth0_user['user_id'],
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
