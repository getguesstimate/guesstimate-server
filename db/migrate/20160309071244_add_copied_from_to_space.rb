class AddCopiedFromToSpace < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :copied_from_id, :integer
  end
end
