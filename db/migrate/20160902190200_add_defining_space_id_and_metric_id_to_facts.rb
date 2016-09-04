class AddDefiningSpaceIdAndMetricIdToFacts < ActiveRecord::Migration
  def change
    add_column :facts, :exporting_space_id, :int
    add_column :facts, :metric_id, :int

    add_index :facts, :exporting_space_id
  end
end
