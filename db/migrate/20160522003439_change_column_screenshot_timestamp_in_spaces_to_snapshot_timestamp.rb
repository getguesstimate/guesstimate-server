class ChangeColumnScreenshotTimestampInSpacesToSnapshotTimestamp < ActiveRecord::Migration[4.2]
  def change
    rename_column :spaces, :screenshot_timestamp, :snapshot_timestamp
  end
end
