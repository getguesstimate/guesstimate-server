class CreateSpaceCheckpoints < ActiveRecord::Migration
  def change
    create_table :space_checkpoints do |t|
      t.json :graph
      t.string :name
      t.text :description
      t.integer :space_id

      t.timestamps null: false
    end

    add_index :space_checkpoints, :space_id
    add_index :space_checkpoints, :created_at
  end
end
