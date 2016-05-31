class UserOrganizationInvitationMailer < ApplicationMailer
  def new_user_invite(invitation)
    @email = invitation.email
    @organization = invitation.organization
    @redirect_url = BASE_URL
    mail to: @email, subject: "Welcome to Guesstimate"
  end
end
