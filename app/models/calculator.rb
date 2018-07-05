class Calculator < ApplicationRecord
  belongs_to :space

  validates_presence_of :space, :title, :input_ids, :output_ids
end
