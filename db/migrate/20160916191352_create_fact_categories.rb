class CreateFactCategories < ActiveRecord::Migration
  def change
    create_table :fact_categories do |t|
      t.integer :organization_id
      t.string :name

      t.timestamps null: false
    end

    add_index :fact_categories, :organization_id
    add_index :fact_categories, :name
  end
end
