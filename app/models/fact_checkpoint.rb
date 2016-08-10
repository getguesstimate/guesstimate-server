class FactCheckpoint < ActiveRecord::Base
  belongs_to :fact
  belongs_to :author, class_name: 'User'

  validates_presence_of :fact, :simulation, :author
end
