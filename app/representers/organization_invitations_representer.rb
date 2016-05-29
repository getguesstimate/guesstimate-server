require 'roar/decorator'

class OrganizationInvitationsRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  collection :to_a, as: 'items', class: UserOrganizationInvitation, decorator: OrganizationInvitationRepresenter
end
