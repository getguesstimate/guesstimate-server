class UserOrganizationMembershipsController < ApplicationController
  before_action :authenticate

  def user_memberships
    @memberships = UserOrganizationMembership.for_user(params[:user_id])
    render json: OrganizationMembershipsRepresenter.new(@memberships).to_json
  end

  def organization_memberships
    unless current_user.member_of?(params[:organization_id])
      head :unauthorized
      return
    end

    @memberships = UserOrganizationMembership.for_organization(params[:organization_id])
    render json: OrganizationMembershipsRepresenter.new(@memberships).to_json
  end
end
