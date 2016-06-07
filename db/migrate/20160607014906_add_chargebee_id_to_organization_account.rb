class AddChargebeeIdToOrganizationAccount < ActiveRecord::Migration
  def change
    add_column :organization_accounts, :chargebee_id, :string
  end
end
