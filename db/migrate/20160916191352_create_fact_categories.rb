class CreateFactCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :fact_categories do |t|
      t.integer :organization_id
      t.string :name

      t.timestamps null: false
    end

    add_index :fact_categories, :organization_id
  end
end
