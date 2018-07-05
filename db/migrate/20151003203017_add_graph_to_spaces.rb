class AddGraphToSpaces < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :graph, :json
  end
end
