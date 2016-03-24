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
  property :creator_id, as: :user_id

  property :creator, as: :user, class: User, embedded: true  do
    property :id
    property :name
    property :picture
  end
end
