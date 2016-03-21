class ChangeSpaceUserId < ActiveRecord::Migration
  def change
    rename_column :spaces, :user_id, :creator_id
  end
end
