class AddPrivateModelCounttoUser < ActiveRecord::Migration
  def change
    add_column :users, :private_access_count, :integer
  end
end
