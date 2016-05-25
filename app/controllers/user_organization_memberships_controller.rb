class UserOrganizationMembershipsController < ApplicationController
  before_action :authenticate, only: [:create_by_email, :destroy]
  before_action :set_membership, only: [:destroy]
  before_action :set_organization, only: [:create_by_email]
  before_action :check_authorization, only: [:create_by_email, :destroy]

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

  def create_by_email
    user = User.find_by_email params[:email]
    if user.nil?
      head 404
      return
    end

    @membership = UserOrganizationMembership.new user: user, organization_id: params[:organization_id]
    if @membership.save
      render json: OrganizationMembershipRepresenter.new(@membership).to_json
    else
      render json: @membership.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @membership.destroy
    head :no_content
  end

  private

  def set_membership
    @membership = UserOrganizationMembership.find(params[:id])
    @organization = @membership.organization
  end

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def check_authorization
    head :unauthorized unless current_user.id == @organization.admin_id
  end
end
