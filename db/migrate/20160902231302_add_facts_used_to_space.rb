class AddFactsUsedToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :imported_fact_ids, :int, array: true
    add_index :spaces, :imported_fact_ids
  end
end
