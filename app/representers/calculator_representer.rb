require 'roar/decorator'

class CalculatorRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :space_id
  property :title
  property :content
  property :input_ids
  property :output_ids

  property :space, embedded: true do
    property :user_id
    property :organization_id
    property :id
    property :name
    property :description
    property :graph
    property :is_private
  end
end
