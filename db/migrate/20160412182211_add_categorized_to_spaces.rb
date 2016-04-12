class AddCategorizedToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :categorized, :bool
  end
end
