class CreateOrganizationSpacePermissions < ActiveRecord::Migration
  def change
    create_table :organization_space_permissions do |t|
      t.integer :space_id
      t.integer :organization_id

      t.timestamps null: false
    end
    add_index :organization_space_permissions, :space_id
    add_index :organization_space_permissions, :organization_id
  end
end
