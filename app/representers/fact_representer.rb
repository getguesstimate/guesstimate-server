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

  collection :dependent_fact_exporting_spaces,
    class: Space,
    decorator: SpaceWithoutOrganizationRepresenter
end
