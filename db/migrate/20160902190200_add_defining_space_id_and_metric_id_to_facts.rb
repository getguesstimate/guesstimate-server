class AddDefiningSpaceIdAndMetricIdToFacts < ActiveRecord::Migration
  def change
    add_column :facts, :exported_from_id, :int
    add_column :facts, :metric_id, :int

    add_index :facts, :exported_from_id
  end
end
