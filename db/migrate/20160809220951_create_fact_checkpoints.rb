class CreateFactCheckpoints < ActiveRecord::Migration[4.2]
  def change
    create_table :fact_checkpoints do |t|
      t.integer :fact_id
      t.integer :author_id
      t.json :simulation
      t.string :name
      t.string :variable_name
      t.string :expression

      t.timestamps null: false
    end

    add_index :fact_checkpoints, :fact_id
    add_index :fact_checkpoints, :author_id
    add_index :fact_checkpoints, :created_at
  end
end
