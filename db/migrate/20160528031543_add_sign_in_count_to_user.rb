class AddSignInCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :sign_in_count, :int, null: false, default: 0
  end
end
