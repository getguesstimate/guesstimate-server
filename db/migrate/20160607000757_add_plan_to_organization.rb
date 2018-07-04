class AddPlanToOrganization < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :plan, :integer, default: 6
  end
end
