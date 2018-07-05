class AddViewcountToSpace < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :viewcount, :int
  end
end
