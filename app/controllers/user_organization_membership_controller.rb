class UserOrganizationMembershipController < ApplicationController
  before_action :ensure_logged_in
  before_action :ensure_member, only: :organization_memberships

  def user_memberships
    @memberships = memberships.for_user(params[:user_id])
    render json: OrganizationMembershipsRepresenter.new(@memberships).to_json
  end

  def organization_memberships
    @memberships = memberships.for_organization(params[:organization_id])
    render json: OrganizationMembershipsRepresenter.new(@memberships).to_json
  end

  private
  def ensure_logged_in
    head :unauthorized unless logged_in?
  end

  def ensure_member
    head :unauthorized unless current_user.member_of?(params[:organization_id])
  end
end
