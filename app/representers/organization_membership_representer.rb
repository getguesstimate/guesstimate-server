require 'roar/decorator'

class OrganizationMembershipRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :user_id
  property :organization_id
  property :invitation_id

  property :user, class: User, embedded: true do
    property :id
    property :username, as: "name"
    property :picture
  end
end
