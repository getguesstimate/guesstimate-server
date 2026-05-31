require "auth0"

class Authentor
  attr_accessor :auth0, :auth0_users

  def initialize
    @auth0 = Auth0Client.new(
      :api_version => 2,
      :client_id => Rails.application.secrets.auth0_client_id,
      :client_secret => Rails.application.secrets.auth0_client_secret,
      :domain => Rails.application.secrets.auth0_api_domain
    )
    @api_params = {connection: Rails.application.secrets.auth0_connection}
  end

  def create_user(params)
    new_auth0_user = @auth0.create_user(params[:email], @api_params.merge(params))
    User.create_from_auth0_user(new_auth0_user)
  end

  def fetch_user(auth0_id)
    begin
      auth0_user = @auth0.user(auth0_id)
    rescue Auth0::NotFound
      # The Management API's user(id) endpoint only resolves *primary* user ids.
      # When a user signs in with an identity that Auth0 has linked as a
      # secondary (e.g. a Google login linked under a primary GitHub account),
      # the token's `sub` is the secondary id and user(id) returns 404.
      # Fall back to searching identities so we can still find the account.
      auth0_user = find_user_by_identity(auth0_id)
      raise if auth0_user.nil?
      # Store the record under the id the frontend authenticates with, so future
      # lookups by this `sub` match without another Auth0 round-trip.
      auth0_user = auth0_user.merge("user_id" => auth0_id)
    end

    user = User.create_from_auth0_user auth0_user
    Rails.logger.info "Created user from auth0 user #{auth0_user}"
  end

  # Looks up an Auth0 user by a (possibly secondary/linked) identity id.
  # `auth0_id` looks like "google-oauth2|1107...", and Auth0 stores the part
  # after the "|" as identities.user_id. Returns the user hash or nil.
  def find_user_by_identity(auth0_id)
    identity_user_id = auth0_id.split("|", 2).last
    result = @auth0.users(
      q: %Q{identities.user_id:"#{identity_user_id}"},
      search_engine: "v3",
      per_page: 1,
      include_totals: true
    )
    (result["users"] || []).first
  end

  def fetch_users
    # Get the last 100 users
    @auth0_users = @auth0.get_users({per_page: 100, page: 0, sort: 'created_at:-1'})

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
