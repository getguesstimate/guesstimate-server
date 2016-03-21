class CreateUserSpacePermissions < ActiveRecord::Migration
  def change
    create_table :user_space_permissions do |t|
      t.integer :space_id
      t.integer :user_id
      t.integer :access_type

      t.timestamps null: false
    end
    add_index :user_space_permissions, :space_id
    add_index :user_space_permissions, :user_id
  end
end
