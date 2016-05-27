class UserOrganizationMembershipMailer < ApplicationMailer
  def send_invite_email(user, organization, redirect_url, password)
    @user = user
    @organization = organization
    @password = password
    @redirect_url = redirect_url
    mail to: @user.email, subject: "Welcome to Guesstimate"
  end
end
