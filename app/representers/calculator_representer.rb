require 'roar/decorator'

class CalculatorRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :space_id
  property :content

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
