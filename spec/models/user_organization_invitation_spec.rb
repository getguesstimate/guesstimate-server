require 'rails_helper'

RSpec.describe UserOrganizationInvitation, type: :model do
  describe '#create' do
    let (:email) { 'foo@bar.com' }
    let (:organization) { FactoryGirl.create :organization }
    subject (:invitation) { FactoryGirl.build :user_organization_invitation, email: email, organization: organization }

    it { is_expected.to be_valid }

    context 'no email' do
      let (:email) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no organization' do
      let (:organization) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'multiple invitations' do
      let (:email2) { 'foo2@bar.com' }
      it 'should be valid with no collision' do
        FactoryGirl.create :user_organization_invitation, email: email2, organization: organization
        is_expected.to be_valid
      end

      it 'should not be valid with collision' do
        FactoryGirl.create :user_organization_invitation, email: email, organization: organization
        is_expected.to_not be_valid
      end
    end
  end
end
