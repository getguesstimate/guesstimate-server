require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe '#create' do
    let (:admin) { FactoryGirl.create(:user) }
    subject (:organization) { FactoryGirl.build(:organization, admin: admin) }

    it { is_expected.to be_valid }

    context 'no admin' do
      let (:admin) { nil }
      it { is_expected.to_not be_valid }
    end
  end

  describe 'after create' do
    let (:admin) { FactoryGirl.create(:user) }
    let (:plan) { 5 }
    let (:organization) { FactoryGirl.create(:organization, admin: admin, plan: plan) }
    subject (:members) {organization.members}

    it { is_expected.to match_array [admin] }

    it 'creates an account' do
      expect(organization.account).to be_present
    end

    context 'on organization_free plan' do
      it 'does not create a subscription' do
        expect_any_instance_of(OrganizationAccount).not_to receive(:create_subscription)
        organization
      end

      it 'does not prefer private models' do
        expect(organization.prefers_private?).to be_falsey
      end
    end

    context 'on organization_basic plan' do
      let (:plan) { 6 }

      it 'creates a subscription' do
        expect_any_instance_of(OrganizationAccount).to receive(:create_subscription).at_least(:once)
        organization
      end

      it 'prefers private models' do
        expect(organization.prefers_private?).to be_truthy
      end
    end
  end
end
