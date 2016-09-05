class AddDefinedFactsCountToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :exported_facts_count, :int, default: 0
  end
end
