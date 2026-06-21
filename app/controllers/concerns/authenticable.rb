# Authenticates requests using Auth0-issued RS256 JWTs.
#
# Replaces the abandoned `knock` gem. Behaviour mirrors the previous setup:
#   * `current_user` returns the User for a valid bearer token, or nil.
#   * `authenticate_user` is a before_action that renders 401 when there is no
#     authenticated user.
#
# The signing key and audience come from config/secrets.yml (Auth0), exactly as
# the old config/initializers/knock.rb did.
module Authenticable
  extend ActiveSupport::Concern

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = user_from_token
  end

  def authenticate_user
    head :unauthorized unless current_user
  end

  private

  def user_from_token
    token = bearer_token
    return nil if token.blank?

    payload = decode_token(token)
    return nil if payload.blank?

    User.from_token_payload(payload)
  rescue JWT::DecodeError, OpenSSL::OpenSSLError, StandardError
    nil
  end

  def bearer_token
    header = request.headers["Authorization"]
    header.to_s.split(" ").last if header.present?
  end

  def decode_token(token)
    JWT.decode(
      token,
      Auth0PublicKey.fetch,
      true,
      algorithms: ["RS256"],
      aud: Rails.application.secrets.auth0_audience,
      verify_aud: true
    ).first
  end

  # Fetches and memoizes the Auth0 tenant's public signing key from its JWKS
  # endpoint (same approach as the old knock initializer).
  module Auth0PublicKey
    def self.fetch
      @public_key ||= begin
        domain = Rails.application.secrets.auth0_api_domain
        jwks_raw = Net::HTTP.get(URI("https://#{domain}/.well-known/jwks.json"))
        jwks_keys = Array(JSON.parse(jwks_raw)["keys"])
        cert = Base64.decode64(jwks_keys[0]["x5c"].first)
        OpenSSL::X509::Certificate.new(cert).public_key
      end
    end
  end
end
