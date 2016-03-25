require 'roar/decorator'

class UserMembershipsRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  collection :to_a, as: 'items', class: UserOrganizationMembership, decorator: UserMembershipRepresenter
end
