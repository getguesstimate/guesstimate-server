class AddInvitationIdToUserOrganizationMembership < ActiveRecord::Migration
  def change
    add_column :user_organization_memberships, :invitation_id, :integer
  end
end
