class AddDefinedFactsCountToSpaces < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :exported_facts_count, :int, default: 0
  end
end
