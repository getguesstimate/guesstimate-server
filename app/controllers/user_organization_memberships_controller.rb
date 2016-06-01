class UserOrganizationMembershipsController < ApplicationController
  before_action :authenticate, only: [:destroy]
  before_action :set_membership, only: [:destroy]
  before_action :check_authorization, only: [:destroy]

  def user_memberships
    # We use a UserOrganizationMemberships scope here to avoid unnecessary DB indirection through the user.
    @memberships = UserOrganizationMembership.for_user(params[:user_id])
    # TODO(matthew): This representer embeds the user's organizations. In getting them, it runs a sql query for every
    # membership in @memberships; which is expensive. We should grab the memberships alone, then all the users
    # organizations alone, and render them to json separately, rather than processing the memberships one at a time.
    render json: UserMembershipsRepresenter.new(@memberships).to_json
  end

  def organization_memberships
    # We use a UserOrganizationMemberships scope here to avoid unnecessary DB indirection through the organization.
    @memberships = UserOrganizationMembership.for_organization(params[:organization_id])
    # TODO(matthew): This representer embeds the organization's users. In getting them, it runs a sql query for every
    # membership in @memberships; which is expensive. We should grab the memberships alone, then all the organization's
    # users alone, and render them to json separately, rather than processing the memberships one at a time.
    render json: OrganizationMembershipsRepresenter.new(@memberships).to_json
  end

  def destroy
    InternalMailer.organization_changed_member_count(@organization, 'removed').deliver_later
    @membership.destroy
    head :no_content
  end

  private
  def set_membership
    @membership = UserOrganizationMembership.find(params[:id])
    @organization = @membership.organization
  end

  def check_authorization
    head :unauthorized unless current_user.id == @organization.admin_id
  end
end
