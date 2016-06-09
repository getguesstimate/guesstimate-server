class AddPlanToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :plan, :integer, default: 6
  end
end
