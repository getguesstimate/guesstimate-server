require 'roar/decorator'

class CalculatorRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :space_id
  property :content
end
