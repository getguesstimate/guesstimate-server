class UserOrganizationInvitationsController < ApplicationController
  before_action :authenticate, :set_entities, :check_authorization

  def organization_invitations
    # We use a UserOrganizationInvitations scope here to avoid unnecessary DB indirection through the organization.
    @invitations = UserOrganizationInvitation.for_organization(params[:organization_id])
    render json: OrganizationInvitationsRepresenter.new(@invitations).to_json
  end

  def invite_by_email
    @invitation = UserOrganizationInvitation.new email: params[:email], organization: @organization
    if @invitation.save
      if @user.nil?
        UserOrganizationInvitationMailer.new_user_invite(@invitation).deliver_later
      else
        return unless add_existing_user
      end
      render json: OrganizationInvitationRepresenter.new(@invitation).to_json
    else
      render json: @invitation.errors, status: :unprocessable_entity
    end
  end

  private

  def add_existing_user
    membership = UserOrganizationMembership.new user: @user, organization: @organization, invitation: @invitation
    if membership.save
      InternalMailer.organization_changed_member_count(@organization, 'added').deliver_later
      return true
    else
      render json: membership.errors, status: :unprocessable_entity
      return false
    end
  end

  def set_entities
    @organization = Organization.find(params[:organization_id])
    @user = User.find_by_email(params[:email])
  end

  def check_authorization
    head :unauthorized unless current_user.id == @organization.admin_id
  end
end
