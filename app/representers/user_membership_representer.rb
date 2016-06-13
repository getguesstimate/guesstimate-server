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
    property :plan_details,
      decorator: PlanRepresenter,
      class: Plan,
      as: 'plan',
      if: ->(user_options:, **) { user_options[:current_user].member_of?(self.id) }
  end
end
