class OrganizationAccount < ApplicationRecord
  belongs_to :organization
  after_create :set_chargebee_id

  def payment_portal
    return false unless has_payment_account
    return ExternalSubscriptions::PaymentPortal.new(chargebee_id)
  end

  def create_subscription(plan_id)
    ExternalSubscriptions::Adapter.create_subscription(chargebee_id, plan_id)
    update_attribute(:has_payment_account, true)
  end

  def set_chargebee_id
    update_attribute(:chargebee_id, "organization-#{organization.id}")
  end
end
