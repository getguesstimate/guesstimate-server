class AddCategoryToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :category, :string
  end
end
