class OrganizationAccount < ActiveRecord::Base
  belongs_to :organization

  def payment_portal
    return false unless chargebee_id
    return ExternalSubscriptions::PaymentPortal.new(chargebee_id)
  end
end
