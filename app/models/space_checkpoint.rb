class SpaceCheckpoint < ApplicationRecord
  belongs_to :space
  belongs_to :author, class_name: 'User'

  validates_presence_of :space_id, :graph
end
