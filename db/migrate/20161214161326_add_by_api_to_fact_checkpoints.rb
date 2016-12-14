class AddByApiToFactCheckpoints < ActiveRecord::Migration
  def change
    add_column :fact_checkpoints, :by_api, :bool
  end
end
