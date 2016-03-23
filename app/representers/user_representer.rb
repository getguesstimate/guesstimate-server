require 'roar/decorator'

class UserRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :name
  property :picture
  property :created_at
  property :updated_at
  property :public_model_count
  property :private_model_count
  property :has_private_access

  property :plan_details,
    decorator: PlanRepresenter,
    class: Plan,
    as: 'plan',
    if: ->(user_options:, **) { user_options[:can_access_account] }

  property :account,
    decorator: AccountRepresenter,
    class: Account,
    if: ->(user_options:, **) { user_options[:can_access_account] }

  collection :memberships, embedded: true, decorator: UserOrganizationMembershipRepresenter, class: UserOrganizationMembership
end
