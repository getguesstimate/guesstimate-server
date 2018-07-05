class ChangeAccountTableName < ActiveRecord::Migration[4.2]
  def change
    rename_table :accounts, :user_accounts
  end
end
