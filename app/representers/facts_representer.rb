require 'roar/decorator'

class FactsRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  collection :to_a, as: 'items', class: Fact do
    property :id
    property :name
    property :value
    property :variable_name
  end
end
