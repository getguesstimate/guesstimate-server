class AddCategorizedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :categorized, :bool
  end
end
