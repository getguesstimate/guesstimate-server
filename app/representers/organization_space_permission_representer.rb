require 'roar/decorator'

class OrganizationSpacePermissionRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id

  property :space, class: Space, embedded: true  do
    property :id
    property :name
    property :description
    property :is_private
  end
end
