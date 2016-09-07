require 'roar/decorator'

class FactRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :organization_id
  property :name
  property :expression
  property :variable_name
  property :simulation
  property :created_at
  property :updated_at
  property :exported_from_id
  property :metric_id
  property :imported_to_intermediate_space_ids
end
