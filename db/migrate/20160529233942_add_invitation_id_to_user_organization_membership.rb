class AddInvitationIdToUserOrganizationMembership < ActiveRecord::Migration[4.2]
  def change
    add_column :user_organization_memberships, :invitation_id, :integer
  end
end
