require 'roar/decorator'

class FactCategoryRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :organization_id
  property :name
end
