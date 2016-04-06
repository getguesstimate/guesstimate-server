require "auth0"

class Authentor
  attr_accessor :auth0, :auth0_users

  def initialize
    @auth0 = Auth0Client.new(
      :api_version => 2,
      :token => Rails.application.secrets.auth0_api_token,
      :domain => Rails.application.secrets.auth0_api_domain
    )

    find_user_count = @auth0.get_users({per_page: 0, page: 0, include_totals: true})
    total = find_user_count["total"]
    go_to_page = total / 100

    @auth0_users = @auth0.get_users({per_page: 100, page: go_to_page})

    puts "GOING TO PAGE #{total}, found users with count #{@auth0_users.count}"

    if !@auth0_users || @auth0_users.empty?
      Rails.logger.error "Auth0 did not return users when attempting to Sync!"
    end
  end

  def run
    new_users = new_auth0_users
    new_users.each do |auth0_user|
      attributes = {
          name: auth0_user['name'],
          username: auth0_user['nickname'],
          email: auth0_user['email'],
          company: auth0_user['company'],
          locale: auth0_user['locale'],
          location: auth0_user['location'],
          gender: auth0_user['gender'],
          picture: auth0_user['picture'],
          auth0_id: auth0_user['user_id'],
      }
      user = User.create(attributes)
      user.identify
      puts "Created user with attributes #{attributes}"
      Rails.logger.info "Created user with attributes #{attributes}"
    end
  end

  def new_auth0_users
    @auth0_users.select{|e| !User.exists?(auth0_id: e["user_id"])}
  end
end
