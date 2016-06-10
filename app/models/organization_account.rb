class OrganizationAccount < ActiveRecord::Base
  belongs_to :organization

  def payment_portal
    return false unless has_payment_account
    return ExternalSubscriptions::PaymentPortal.new(chargebee_id)
  end

  def create_subscription(plan_id)
    ExternalSubscriptions::Adapter.create_subscription(chargebee_id, plan_id)
    update_attribute(:has_payment_account, true)

    if self[:chargebee_id].nil?
      update_attribute(:chargebee_id, chargebee_id)
    end
  end

  def chargebee_id
    self[:chargebee_id] || "organization-#{organization.id}"
  end
end
