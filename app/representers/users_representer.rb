require 'roar/decorator'

class UsersRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  collection :to_a, as: 'items', class: User do
    property :id
    property :username, as: "name"
    property :picture
    property :created_at
    property :updated_at
    property :public_model_count
    property :private_model_count
    property :needs_tutorial

    nested :plan do
      property :private_model_limit
    end
  end
end
