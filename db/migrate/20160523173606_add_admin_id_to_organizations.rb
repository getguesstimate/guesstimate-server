class AddAdminIdToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :admin_id, :int
    add_index :organizations, :admin_id
  end
end
