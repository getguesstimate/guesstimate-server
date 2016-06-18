class CreateCalculators < ActiveRecord::Migration
  def change
    create_table :calculators do |t|
      t.integer :space_id
      t.text :content

      t.timestamps null: false
    end
    add_index :calculators, :space_id
  end
end
