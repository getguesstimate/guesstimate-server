class AddSimulationToFact < ActiveRecord::Migration[4.2]
  def change
    add_column :facts, :simulation, :json
    remove_column :facts, :values
  end
end
