class UserOrganizationInvitationMailer < ApplicationMailer
  def new_user_invite(invitation)
    @email = invitation.email
    @organization = invitation.organization
    @inviter = @organization.admin
    @redirect_url = BASE_URL
    mail to: @email, subject: "#{@inviter.name} invited you to join #{@organization.name} on Guesstimate"
  end
end
