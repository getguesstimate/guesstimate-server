class AddCompanyIndustryRoleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :company, :string
    add_column :users, :industry, :string
    add_column :users, :role, :string
  end
end
