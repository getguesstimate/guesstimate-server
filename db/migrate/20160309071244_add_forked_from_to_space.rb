class AddForkedFromToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :forked_from_id, :integer
  end
end
