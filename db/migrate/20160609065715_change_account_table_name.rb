class ChangeAccountTableName < ActiveRecord::Migration
  def change
    rename_table :accounts, :user_accounts
  end
end
