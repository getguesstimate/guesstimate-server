class AddNeedsTutorialToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :needs_tutorial, :bool, default: false
  end
end
