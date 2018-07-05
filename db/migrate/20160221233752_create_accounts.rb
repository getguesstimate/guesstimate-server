class CreateAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :accounts do |t|
      t.integer :user_id
      t.boolean :has_payment_account
    end
  end
end
