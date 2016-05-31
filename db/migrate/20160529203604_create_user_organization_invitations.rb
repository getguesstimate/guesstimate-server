class CreateUserOrganizationInvitations < ActiveRecord::Migration
  def change
    create_table :user_organization_invitations do |t|
      t.string :email
      t.integer :organization_id

      t.timestamps null: false
    end

    add_index :user_organization_invitations, :email
    add_index :user_organization_invitations, :organization_id
  end
end
