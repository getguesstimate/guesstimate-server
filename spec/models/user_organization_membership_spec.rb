require 'rails_helper'

RSpec.describe UserOrganizationMembership, type: :model do
  describe '#create' do
    let (:user) { FactoryBot.create :user }
    let (:organization) { FactoryBot.create :organization }
    subject (:membership) { FactoryBot.build :user_organization_membership, user: user, organization: organization }

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
      let (:user2) { FactoryBot.create :user }
      it 'should be valid with no collision' do
        FactoryBot.create :user_organization_membership, user: user2, organization: organization
        is_expected.to be_valid
      end

      it 'should not be valid with collision' do
        FactoryBot.create :user_organization_membership, user: user, organization: organization
        is_expected.to_not be_valid
      end
    end
  end
end
