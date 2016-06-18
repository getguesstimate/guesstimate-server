class Calculator < ActiveRecord::Base
  belongs_to :space

  validates_presence_of :space
end
