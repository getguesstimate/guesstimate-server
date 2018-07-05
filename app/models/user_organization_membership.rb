class UserOrganizationMembership < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  belongs_to :invitation, class_name: 'UserOrganizationInvitation'

  validates_presence_of :organization, :user
  validates_uniqueness_of :organization_id, scope: :user_id

  scope :for_organization, -> (organization_id) { where(organization_id: organization_id) }
  scope :for_user, -> (user_id) { where(user_id: user_id) }

  after_destroy :delete_invitation

  private
  def delete_invitation
    invitation.destroy if invitation.present?
  end
end
