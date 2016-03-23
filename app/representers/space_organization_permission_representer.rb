require 'roar/decorator'

class SpaceOrganizationPermissionRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id

  property :organization, class: Organization, embedded: true  do
    property :id
    property :name
  end
end
