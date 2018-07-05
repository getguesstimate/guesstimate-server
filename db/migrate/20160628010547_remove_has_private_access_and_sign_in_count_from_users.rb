class RemoveHasPrivateAccessAndSignInCountFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :has_private_access, :boolean
    remove_column :users, :sign_in_count, :integer
  end
end
