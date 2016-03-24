require 'roar/decorator'

class OrganizationUserMembershipRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :user_id
  property :organization_id
end
