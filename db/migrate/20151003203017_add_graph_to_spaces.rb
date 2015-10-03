class AddGraphToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :graph, :json
  end
end
