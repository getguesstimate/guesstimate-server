class CreateCalculators < ActiveRecord::Migration
  def change
    create_table :calculators do |t|
      t.integer :space_id
      t.string :title
      t.text :content
      t.string :inputs, array: true
      t.string :outputs, array: true

      t.timestamps null: false
    end
    add_index :calculators, :space_id
  end
end
