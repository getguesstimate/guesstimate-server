require 'roar/decorator'

class OrganizationUserMembershipRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :member_type

  property :user, class: User, embedded: true  do
    property :id
    property :name
    property :picture
  end
end
