class UserOrganizationInvitation < ActiveRecord::Base
  belongs_to :organization

  validates_presence_of :organization
  validates :email, presence: true, format: /@/

  validates_uniqueness_of :organization, scope: :email

  scope :for_organization, -> (organization_id) { where(organization_id: organization_id) }
  scope :for_email, -> (email) { where(email: email) }
end
