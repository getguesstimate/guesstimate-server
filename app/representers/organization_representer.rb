require 'roar/decorator'

class OrganizationRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :name

  collection :memberships, decorator: OrganizationUserMembershipRepresenter, class: UserOrganizationMembership
  collection :permissions, decorator: OrganizationSpacePermissionRepresenter, class: OrganizationSpacePermission
end
