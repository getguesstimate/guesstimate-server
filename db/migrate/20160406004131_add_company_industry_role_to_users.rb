class AddCompanyIndustryRoleToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :company, :string
    add_column :users, :industry, :string
    add_column :users, :role, :string
  end
end
