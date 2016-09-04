class AddDefinedFactsCountToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :exported_facts_count, :int
  end
end
