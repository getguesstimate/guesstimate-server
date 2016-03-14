class AddCopiedFromToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :copied_from_id, :integer
  end
end
