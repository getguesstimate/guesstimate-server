class AddUserIdToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :user_id, :integer
  end
end
