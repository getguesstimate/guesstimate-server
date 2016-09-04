class AddFactsUsedToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :imported_facts, :int, array: true
    add_index :spaces, :imported_facts
  end
end
