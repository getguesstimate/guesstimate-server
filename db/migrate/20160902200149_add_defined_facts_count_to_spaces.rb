class AddDefinedFactsCountToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :defined_facts_count, :int
  end
end
