require 'roar/decorator'

class UserRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  # We use the below hack until we decide what our strategy will be for real names, to keep the client behavior the same.
  property :username, as: "name"
  property :email, if: ->(user_options:, **) { user_options[:is_current_user] }
  property :picture
  property :created_at
  property :updated_at
  property :public_model_count, if: ->(user_options:, **) { user_options[:is_current_user] }
  property :private_model_count, if: ->(user_options:, **) { user_options[:is_current_user] }
  property :has_private_access

  property :plan_details,
    decorator: PlanRepresenter,
    class: Plan,
    as: 'plan',
    if: ->(user_options:, **) { user_options[:is_current_user] }

  property :account,
    decorator: AccountRepresenter,
    class: Account,
    if: ->(user_options:, **) { user_options[:is_current_user] }
end
