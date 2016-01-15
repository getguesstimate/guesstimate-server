class AddPrivateToggleToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :is_private, :boolean
  end
end
