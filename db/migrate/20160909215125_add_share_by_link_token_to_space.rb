class AddShareByLinkTokenToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :shareable_link_token, :string
    add_column :spaces, :shareable_link_enabled, :bool, default: false
  end
end
