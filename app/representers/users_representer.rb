require 'roar/decorator'

class UsersRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  collection :to_a, as: 'items', class: User do
    property :id
    property :name
    property :picture
    property :has_private_access
    property :private_model_count
    property :available_private_model_count
  end
end
