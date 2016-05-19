class AddBigImagesToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :big_screenshot, :string
  end
end
