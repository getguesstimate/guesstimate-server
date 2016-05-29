class UserOrganizationMembershipsController < ApplicationController
  before_action :authenticate, only: [:invite_by_email, :destroy]
  before_action :set_membership, only: [:destroy]
  before_action :set_entities, only: [:invite_by_email]
  before_action :check_authorization, only: [:invite_by_email, :destroy]

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

  def invite_by_email
    if @user.nil?
      invite_new_user
    else
      create_new_membership
    end
  end

  def destroy
    InternalMailer.organization_changed_member_count(@organization, 'removed').deliver_later
    @membership.destroy
    head :no_content
  end

  private

  def invite_new_user
    @invitation = UserOrganizationInvitation.new email: params[:email], organization: @organization
    if @invitation.save
      UserOrganizationInvitationMailer.new_user_invite(@invitation).deliver_later
      render json: OrganizationInvitationRepresenter.new(@invitation).to_json
    else
      render json: @invitation.errors, status: :unprocessable_entity
    end
  end

  def create_new_membership
    @membership = UserOrganizationMembership.new user: @user, organization: @organization
    if @membership.save
      InternalMailer.organization_changed_member_count(@organization, 'added').deliver_later
      render json: OrganizationMembershipRepresenter.new(@membership).to_json
    else
      render json: @membership.errors, status: :unprocessable_entity
    end
  end

  def set_membership
    @membership = UserOrganizationMembership.find(params[:id])
    @organization = @membership.organization
  end

  def set_entities
    @organization = Organization.find(params[:organization_id])
    @user = User.find_by_email(params[:email])
  end

  def check_authorization
    head :unauthorized unless current_user.id == @organization.admin_id
  end
end
