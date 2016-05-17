class SpaceCheckpoint < ActiveRecord::Base
  belongs_to :space

  validates_presence_of :space_id, :graph
end
