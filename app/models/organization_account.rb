class OrganizationAccount < ActiveRecord::Base
  belongs_to :organization

  def new_trial_subscription(plan_id)
    ExternalSubscriptions::NewTrialSubscription.new(account_id, plan_id)
    self.update_attribute(:has_payment_account, true)
  end

  def account_id
    "organization-#{organization.id}"
  end

end
