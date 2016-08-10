class AddNeedsTutorialToUser < ActiveRecord::Migration
  def change
    add_column :users, :needs_tutorial, :bool, default: false
  end
end
