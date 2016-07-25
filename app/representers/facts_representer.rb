require 'roar/decorator'

class FactsRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  collection :to_a, as: 'items', class: Fact do
    property :id
    property :organization_id
    property :name
    property :expression
    property :variable_name
    property :created_at
    property :updated_at
  end
end
