class AddPictureToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :picture, :string
  end
end
