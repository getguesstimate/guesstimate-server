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
  end
end
