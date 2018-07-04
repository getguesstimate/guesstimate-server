class AddScreenshotToSpace < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :screenshot, :string
  end
end
