require 'roar/decorator'

class OrganizationUserMembershipRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  collection :to_a, as: 'items', class: UserOrganizationMembership, decorator: OrganizationUserMembershipRepresenter
end
