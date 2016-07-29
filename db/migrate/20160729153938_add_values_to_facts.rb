class AddValuesToFacts < ActiveRecord::Migration
  def change
    add_column :facts, :values, :integer, array: true
  end
end
