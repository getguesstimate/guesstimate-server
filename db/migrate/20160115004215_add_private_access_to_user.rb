class AddPrivateAccessToUser < ActiveRecord::Migration
  def change
    add_column :users, :has_private_access, :boolean
  end
end
