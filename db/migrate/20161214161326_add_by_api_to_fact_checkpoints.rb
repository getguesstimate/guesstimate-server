class AddByApiToFactCheckpoints < ActiveRecord::Migration[4.2]
  def change
    add_column :fact_checkpoints, :by_api, :bool
  end
end
