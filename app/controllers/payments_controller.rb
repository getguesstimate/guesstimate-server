class PaymentsController < ApplicationController
  #GET /new_checkout_iframe
  def new
    info = {subscription: {plan_id: 'small'}, customer: {id: current_user.id}, embed: true, iframe_messaging: true}
    begin
      chargebee_response = ChargeBee::HostedPage.checkout_new(info).hosted_page
      json_response = {url: chargebee_response.url, website_name: Rails.application.secrets.chargebee_site}
      render json: json_response.to_json
    rescue => ex
      puts ex
    end
  end

  def edit
    redirect_url = params['redirect_url'] || 'www.getguesstimate.com'
    begin
      chargebee_response = ChargeBee::PortalSession.create({redirect_url: redirect_url, customer: {id: current_user}})
      json_response = {url: chargebee_response.portal_session.access_url}
      render json: json_response.to_json
    rescue => ex
      puts ex
    end
  end

  def synchronization
    subscriptions = ChargeBee::Subscription.subscriptions_for_customer(User.first.id, :limit => 5).to_a
    first = subscriptions[0].subscription
    render json: {plan_id: first.plan_id}.to_json
  end
end
