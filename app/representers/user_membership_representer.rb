require 'roar/decorator'

class UserMembershipRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :user_id
  property :organization_id

  property :organization, class: Organization, embedded: true, decorator: OrganizationRepresenter
end
