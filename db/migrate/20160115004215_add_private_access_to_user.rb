class AddPrivateAccessToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :has_private_access, :boolean
  end
end
