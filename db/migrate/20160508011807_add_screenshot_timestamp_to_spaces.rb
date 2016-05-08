class AddScreenshotTimestampToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :screenshot_timestamp, :datetime
  end
end
