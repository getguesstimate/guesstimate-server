# Preview all emails at http://localhost:3000/rails/mailers/user_organization_membership_mailer
class UserOrganizationInvitationMailerPreview < ActionMailer::Preview
  def new_user_invite
    invitation = FactoryGirl.create(:user_organization_invitation)
    UserOrganizationMembershipMailer.new_user_invite invitation
  end
end
