require 'rails_helper'

RSpec.describe UserOrganizationMembership, type: :model do
  describe '#create' do
    let (:user) { FactoryGirl.create :user }
    let (:organization) { FactoryGirl.create :organization }
    let (:member_type) { :admin }
    subject (:membership) { FactoryGirl.build :user_organization_membership, user: user, organization: organization, member_type: member_type }

    it { is_expected.to be_valid }

    context 'no user' do
      let (:user) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no organization' do
      let (:organization) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no member_type' do
      let (:member_type) { nil }
      it { is_expected.to_not be_valid }
    end
  end
end
