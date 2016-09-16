class AddCategoryIdToFacts < ActiveRecord::Migration
  def change
    add_column :facts, :category_id, :integer

    add_index :facts, :category_id
  end
end
