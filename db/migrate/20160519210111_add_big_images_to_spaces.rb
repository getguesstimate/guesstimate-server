class AddBigImagesToSpaces < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :big_screenshot, :string
  end
end
