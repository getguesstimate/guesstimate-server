class AddPictureToOrganization < ActiveRecord::Migration[4.2]
  def change
    add_column :organizations, :picture, :string
  end
end
