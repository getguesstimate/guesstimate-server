class CreateOrganizationAccount < ActiveRecord::Migration[4.2]
  def change
    create_table :organization_accounts do |t|
      t.integer :organization_id
      t.boolean :has_payment_account
    end
  end
end
