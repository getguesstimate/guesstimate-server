class AddValuesToFacts < ActiveRecord::Migration[4.2]
  def change
    add_column :facts, :values, :integer, array: true
  end
end
