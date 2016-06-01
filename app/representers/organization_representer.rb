require 'roar/decorator'

class OrganizationRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :name
  property :picture
  property :admin_id

  property :admin, class: User, embedded: true  do
    property :id
    property :username, as: "name"
    property :picture
  end

  collection :invitations, class: UserOrganizationInvitation, decorator: OrganizationInvitationRepresenter, if: ->(user_options:, **) { user_options[:current_user_is_member] }
  collection :memberships, class: UserOrganizationMembership, decorator: OrganizationMembershipRepresenter, if: ->(user_options:, **) { user_options[:current_user_is_admin] }
end
