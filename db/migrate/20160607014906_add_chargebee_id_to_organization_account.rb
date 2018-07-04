class AddChargebeeIdToOrganizationAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :organization_accounts, :chargebee_id, :string
  end
end
