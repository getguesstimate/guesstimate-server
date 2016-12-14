class AddApiTokenToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :api_token, :string
    add_column :organizations, :api_enabled, :bool
  end
end
