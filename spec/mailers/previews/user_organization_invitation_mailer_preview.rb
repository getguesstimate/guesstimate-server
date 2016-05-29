# Preview all emails at http://localhost:3000/rails/mailers/user_organization_membership_mailer
<<<<<<< HEAD:spec/mailers/previews/user_organization_invitation_mailer_preview.rb
class UserOrganizationInvitationMailerPreview < ActionMailer::Preview
  # TODO(matthew): Configure later.
=======
class UserOrganizationMembershipMailerPreview < ActionMailer::Preview
  def new_user_invite
    organization = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user)
    password = "password"
    redirect_url = "fake"
    UserOrganizationMembershipMailer.new_user_invite user, organization, redirect_url, password
  end
>>>>>>> master:spec/mailers/previews/user_organization_membership_mailer_preview.rb
end
