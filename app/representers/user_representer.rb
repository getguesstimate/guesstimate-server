require 'roar/decorator'

class UserRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :name
  property :picture
  property :has_private_access
  property :created_at
  property :private_model_count
  property :available_private_model_count
end
