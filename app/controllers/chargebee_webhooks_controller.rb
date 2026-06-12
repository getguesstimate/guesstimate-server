class ChargebeeWebhooksController < ApplicationController
  before_action :authenticate_webhook!

  # POST /chargebee/webhooks
  # Chargebee pushes every billing event here (subscription created, cancelled,
  # renewed, changed, ...). We don't trust the payload contents; we just take
  # the customer id and re-sync that user's account from the Chargebee API.
  def create
    user = User.find_by(id: customer_id)
    user.account.synchronize! if user
    render json: {}
  end

  private

  def customer_id
    params.dig(:content, :customer, :id) ||
      params.dig(:content, :subscription, :customer_id)
  end

  def authenticate_webhook!
    authenticate_or_request_with_http_basic('chargebee') do |username, password|
      expected_username = Rails.application.secrets[:chargebee_webhook_username].to_s
      expected_password = Rails.application.secrets[:chargebee_webhook_password].to_s
      expected_password.present? &&
        ActiveSupport::SecurityUtils.secure_compare(username, expected_username) &
        ActiveSupport::SecurityUtils.secure_compare(password, expected_password)
    end
  end
end
