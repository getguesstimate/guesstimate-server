require "auth0"

class Authentor
  attr_accessor :auth0, :auth0_users

  def initialize
    @auth0 = Auth0Client.new(
      :api_version => 2,
      :token => Rails.application.secrets.auth0_api_token,
      :domain => Rails.application.secrets.auth0_api_domain
    )
    @api_params = {connection: Rails.application.secrets.auth0_connection}
  end

  def create_user(params)
    new_auth0_user = @auth0.create_user(params[:email], @api_params.merge(params))
    User.create_from_auth0_user(new_auth0_user)
  end

  def fetch_users
    find_user_count = @auth0.get_users({per_page: 0, page: 0, include_totals: true})
    total = find_user_count["total"]
    go_to_page = total / 100

    @auth0_users = @auth0.get_users({per_page: 100, page: go_to_page})

    puts "GOING TO PAGE #{total}, found users with count #{@auth0_users.count}"

    if !@auth0_users || @auth0_users.empty?
      Rails.logger.error "Auth0 did not return users when attempting to Sync!"
    end

    new_users = new_auth0_users
    new_users.each do |auth0_user|
      user = User.create_from_auth0_user auth0_user
      Rails.logger.info "Created user from auth0 user #{auth0_user}"
    end
  end

  def new_auth0_users
    @auth0_users.select{|e| !User.exists?(auth0_id: e["user_id"])}
  end
end
