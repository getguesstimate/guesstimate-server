class CreateUserOrganizationMemberships < ActiveRecord::Migration
  def change
    create_table :user_organization_memberships do |t|
      t.integer :user_id
      t.integer :organization_id
      t.integer :member_type

      t.timestamps null: false
    end
    add_index :user_organization_memberships, :user_id
    add_index :user_organization_memberships, :organization_id
  end
end
