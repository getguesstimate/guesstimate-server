class UserOrganizationMembership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  validates_presence_of :organization, :user

  scope :for_organization, -> (organization_id) { where(organization_id: organization_id) }
  scope :for_user, -> (user_id) { where(user_id: user_id) }
end
