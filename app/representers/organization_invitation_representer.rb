require 'roar/decorator'

class OrganizationInvitationRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :email
  property :organization_id
end
