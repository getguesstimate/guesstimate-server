class AddPrivateToggleToSpace < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :is_private, :boolean
  end
end
