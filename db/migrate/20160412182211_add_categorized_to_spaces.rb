class AddCategorizedToSpaces < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :categorized, :bool
  end
end
