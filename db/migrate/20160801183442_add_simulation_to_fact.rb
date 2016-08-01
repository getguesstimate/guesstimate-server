class AddSimulationToFact < ActiveRecord::Migration
  def change
    add_column :facts, :simulation, :json
    remove_column :facts, :values
  end
end
