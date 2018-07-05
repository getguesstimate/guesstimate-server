class CreateCalculators < ActiveRecord::Migration[4.2]
  def change
    create_table :calculators do |t|
      t.integer :space_id
      t.string :title
      t.text :content
      t.string :input_ids, array: true
      t.string :output_ids, array: true

      t.timestamps null: false
    end
    add_index :calculators, :space_id
  end
end
