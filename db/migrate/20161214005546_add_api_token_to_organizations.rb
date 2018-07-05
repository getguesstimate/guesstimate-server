class AddApiTokenToOrganizations < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :api_token, :string
    add_column :organizations, :api_enabled, :bool
  end
end
