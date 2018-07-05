class AddOrganizationIdToSpace < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :organization_id, :int
  end
end
