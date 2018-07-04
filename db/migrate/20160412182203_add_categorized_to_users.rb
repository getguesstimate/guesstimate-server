class AddCategorizedToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :categorized, :bool
  end
end
