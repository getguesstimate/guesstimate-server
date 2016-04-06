class AddCompanyIndustryRoleJobTitleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :company, :string
    add_column :users, :industry, :string
    add_column :users, :role, :string
    add_column :users, :job_title, :string
  end
end
