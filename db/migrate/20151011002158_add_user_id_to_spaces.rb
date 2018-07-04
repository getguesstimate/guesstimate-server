class AddUserIdToSpaces < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :user_id, :integer
  end
end
