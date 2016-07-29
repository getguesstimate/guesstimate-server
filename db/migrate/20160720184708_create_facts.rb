class CreateFacts < ActiveRecord::Migration
  def change
    create_table :facts do |t|
      t.integer :organization_id
      t.string :name
      t.string :variable_name
      t.string :expression

      t.timestamps null: false
    end

    add_index :facts, :organization_id
  end
end
