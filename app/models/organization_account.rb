class OrganizationAccount < ActiveRecord::Base
  belongs_to :organization

  def payment_portal
    return false unless chargebee_id
    return ExternalSubscriptions::PaymentPortal.new(chargebee_id)
  end

  #Outline for later
  #def new_trial_subscription()
    #chargebee_id = "organization-#{organization.id}"
    #ExternalSubscriptions::NewTrialSubscription.new(chargebee_id, 'organization_basic')
    #self.update_attribute(:has_payment_account, true)
    #self.update_attribute(:chargebee_id, chargebee_id)
  #end
end
