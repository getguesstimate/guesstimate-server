require 'roar/decorator'

class UserMembershipRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :user_id
  property :organization_id

  property :organization, class: Organization, embedded: true do
    property :id
    property :admin_id
    property :name
    property :picture
  end
end
