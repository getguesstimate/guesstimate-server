class UserOrganizationMembershipsController < ApplicationController
  before_action :authenticate, only: [:destroy]
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
    @membership = UserOrganizationMembership.find(params[:id])
    if current_user.id == @membership.organization.admin_id
      @membership.destroy
      head :no_content
    else
      head :unauthorized
    end
  end
end
