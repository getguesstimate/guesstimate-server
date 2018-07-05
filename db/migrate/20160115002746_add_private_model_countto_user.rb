class AddPrivateModelCounttoUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :private_access_count, :integer
  end
end
