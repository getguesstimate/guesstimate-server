class AddCategoryToSpaces < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :category, :string
  end
end
