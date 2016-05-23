class ChangeColumnScreenshotTimestampInSpacesToSnapshotTimestamp < ActiveRecord::Migration
  def change
    rename_column :spaces, :screenshot_timestamp, :snapshot_timestamp
  end
end
