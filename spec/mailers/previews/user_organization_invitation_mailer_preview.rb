# Preview all emails at http://localhost:4000/rails/mailers/user_organization_invitation_mailer
class UserOrganizationInvitationMailerPreview < ActionMailer::Preview
  def new_user_invite
    invitation = FactoryGirl.create(:user_organization_invitation)
    UserOrganizationInvitationMailer.new_user_invite invitation
  end
end
