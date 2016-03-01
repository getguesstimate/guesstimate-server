class Account < ActiveRecord::Base
  belongs_to :user

  def new_subscription_iframe(plan_id)
    return false if has_payment_account
    return ExternalSubscriptions::NewSubscriptionIframe.new(user.id, plan_id)
  end

  def payment_portal
    return false unless has_payment_account
    return ExternalSubscriptions::PaymentPortal.new(user.id)
  end

  def synchronize!
    synchronize_has_payment_account!
    synchronize_subscription!
  end

  private

  def synchronize_has_payment_account!
    self.update_attribute(:has_payment_account, external_has_account)
  end

  ## TODO: Add error if the external_subscription does not match something in the database
  def synchronize_subscription!
    return false unless has_payment_account
    user.update_attribute(:plan, external_subscription)
  end

  def external_has_account
    ExternalSubscriptions::Adapter.has_account(user.id)
  end

  def external_subscription
    return false unless has_payment_account
    ExternalSubscriptions::Adapter.subscription(user.id)
  end
end
