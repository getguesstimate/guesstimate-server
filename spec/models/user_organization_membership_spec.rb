require 'rails_helper'

RSpec.describe UserOrganizationMembership, type: :model do
  describe '#create' do
    let (:user) { FactoryGirl.create :user }
    let (:organization) { FactoryGirl.create :organization }
    subject (:membership) { FactoryGirl.build :user_organization_membership, user: user, organization: organization }

    it { is_expected.to be_valid }

    context 'no user' do
      let (:user) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no organization' do
      let (:organization) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'multiple memberships' do
      let (:user2) { FactoryGirl.create :user }
      it 'should be valid with no collision' do
        FactoryGirl.create :user_organization_membership, user: user2, organization: organization
        is_expected.to be_valid
      end

      it 'should not be valid with collision' do
        FactoryGirl.create :user_organization_membership, user: user, organization: organization
        is_expected.to_not be_valid
      end
    end
  end
end
