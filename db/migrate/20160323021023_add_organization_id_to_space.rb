class AddOrganizationIdToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :organization_id, :int
  end
end
