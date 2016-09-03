class AddFactsUsedToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :facts_used, :int, array: true
    add_index :spaces, :facts_used
  end
end
