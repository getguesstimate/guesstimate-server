class UserOrganizationMembershipsController < ApplicationController
  before_action :authenticate, only: [:destroy]
  before_action :set_membership, only: [:destroy]
  before_action :check_authorization, only: [:destroy]

  def user_memberships
    # We use a UserOrganizationMemberships scope here to avoid unnecessary DB indirection through the user.
    @memberships = UserOrganizationMembership.for_user(params[:user_id])
    render json: UserMembershipsRepresenter.new(@memberships).to_json
  end

  def organization_memberships
    # We use a UserOrganizationMemberships scope here to avoid unnecessary DB indirection through the organization.
    @memberships = UserOrganizationMembership.for_organization(params[:organization_id])
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
