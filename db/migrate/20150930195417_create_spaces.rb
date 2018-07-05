class CreateSpaces < ActiveRecord::Migration[4.2]
  def change
    create_table :spaces do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end
