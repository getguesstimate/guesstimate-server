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
  property :screenshot
  property :big_screenshot

  property :user, class: User, embedded: true  do
    property :id
    property :username, as: "name"
    property :picture
  end

  property :organization, embedded: true, class: Organization do
    property :id
    property :admin_id
    property :name
    property :picture

    property :plan_details,
      decorator: PlanRepresenter,
      class: Plan,
      as: 'plan',
      if: ->(user_options:, **) { user_options[:current_user_is_member] }
  end
end
