class AddDefiningSpaceIdAndMetricIdToFacts < ActiveRecord::Migration[4.2]
  def change
    add_column :facts, :exported_from_id, :int
    add_column :facts, :metric_id, :string

    add_index :facts, :exported_from_id
  end
end
