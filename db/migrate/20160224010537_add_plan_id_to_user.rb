class AddPlanIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :plan, :integer, default: 1
  end
end
