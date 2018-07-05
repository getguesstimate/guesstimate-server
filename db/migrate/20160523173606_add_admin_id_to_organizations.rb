class AddAdminIdToOrganizations < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :admin_id, :int
    add_index :organizations, :admin_id
  end
end
