class UserOrganizationInvitationMailer < ApplicationMailer
  def new_user_invite(invitation, sign_up_required)
    @email = invitation.email
    @organization = invitation.organization
    @action = sign_up_required ? "Sign up" : "Log in"
    @inviter = @organization.admin
    @redirect_url = BASE_URL
    mail to: @email, subject: "#{@inviter.name} invited you to join #{@organization.name} on Guesstimate"
  end
end
