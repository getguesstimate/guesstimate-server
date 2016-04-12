class AddScreenshotToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :screenshot, :string
  end
end
