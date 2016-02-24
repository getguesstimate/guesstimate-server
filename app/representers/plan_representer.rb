require 'roar/decorator'

class PlanRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :name
  property :id
  property :private_model_limit
end
