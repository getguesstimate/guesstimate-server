require 'roar/decorator'

class UserOrganizationMembershipRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id

  property :organization, class: Organization, embedded: true  do
    property :id
    property :name
  end
end
