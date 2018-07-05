class FactCheckpoint < ApplicationRecord
  belongs_to :fact
  belongs_to :author, class_name: 'User'

  validates_presence_of :fact, :simulation
  validates_presence_of :author, unless: :by_api
end
