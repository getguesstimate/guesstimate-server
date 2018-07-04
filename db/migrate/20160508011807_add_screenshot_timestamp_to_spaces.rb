class AddScreenshotTimestampToSpaces < ActiveRecord::Migration[4.2]
  def change
    add_column :spaces, :screenshot_timestamp, :datetime
  end
end
