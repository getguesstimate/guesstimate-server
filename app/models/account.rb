class Account < ActiveRecord::Base
  belongs_to :user

  def new_subscription_iframe(plan_id)
    info = {
      subscription: {
        plan_id: plan_id
      },
      customer: {
        id: user.id
      },
      embed: true,
      iframe_messaging: true
    }
    chargebee_response = ChargeBee::HostedPage.checkout_new(info).hosted_page
    response = {href: chargebee_response.url, website_name: Rails.application.secrets.chargebee_site}
    return response
  end

  RESOURCE_NOT_FOUND = 404

  def payment_portal
    redirect_url = 'http://www.getguesstimate.com'
    begin
      chargebee_response = ChargeBee::PortalSession.create({
        redirect_url: redirect_url,
        customer: {id: user.id}
      })
      return chargebee_response.portal_session.access_url
    rescue Exception => ex
      if (ex.cause.http_code == RESOURCE_NOT_FOUND)
        return false
      else
        raise ex
      end
    end
  end

  def synchronize!
    synchronize_has_payment_account!
    synchronize_subscription! if has_payment_account
  end

  private
  def synchronize_has_payment_account!
    account = self
    account.update_attribute(:has_payment_account,  chargebee_has_payment_account)
  end

  def chargebee_has_payment_account
    begin
      ChargeBee::Customer.retrieve(user.id)
    rescue Exception => ex
      if ex.cause.http_code === 404
        return false
      else
        raise ex
      end
    end
    return true
  end

  def chargebee_subscription
    subscriptions = ChargeBee::Subscription.subscriptions_for_customer(user.id, :limit => 5).to_a
    first = subscriptions[0].subscription
    new_plan = first.plan_id
    return new_plan
  end

  def synchronize_subscription!
  end
end
