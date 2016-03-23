require 'roar/decorator'

class SpacesRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  collection :to_a, as: 'items', class: Space do
    property :id
    property :name
    property :description
    property :created_at
    property :updated_at
    property :is_private
    property :user_id
    property :organization_id
  end
end
