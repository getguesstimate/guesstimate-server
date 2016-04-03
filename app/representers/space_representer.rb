require 'roar/decorator'

class SpaceRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :name
  property :description
  property :created_at
  property :updated_at
  property :graph
  property :is_private
  property :user_id
  property :organization_id

  property :user, class: User, embedded: true  do
    property :id
    property :username, as: "name"
    property :picture
  end

  property :organization, embedded: true, class: Organization, decorator: OrganizationRepresenter
end
