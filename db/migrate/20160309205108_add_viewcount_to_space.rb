class AddViewcountToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :viewcount, :int
  end
end
