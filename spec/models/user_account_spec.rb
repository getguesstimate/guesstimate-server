require 'rails_helper'

RSpec.describe UserAccount, type: :model do
  let(:user) { FactoryBot.create(:user, plan: :personal_lite) }
  let(:account) { user.account }

  describe '#new_subscription_iframe' do
    it 'is blocked for users on a live paid plan' do
      account.update_attribute(:has_payment_account, true)
      expect(account.new_subscription_iframe('personal_lite')).to eq false
    end

    it 'is allowed for free users with a payment account (cancelled subscription)' do
      user.update_attribute(:plan, 'personal_free')
      account.update_attribute(:has_payment_account, true)
      expect(account.new_subscription_iframe('personal_lite')).to be_a ExternalSubscriptions::NewSubscriptionIframe
    end

    it 'is allowed for users without a payment account' do
      expect(account.new_subscription_iframe('personal_lite')).to be_a ExternalSubscriptions::NewSubscriptionIframe
    end
  end

  describe '#synchronize!' do
    before do
      allow(ExternalSubscriptions::Adapter).to receive(:has_account).and_return(true)
    end

    it 'sets the plan from the live external subscription' do
      allow(ExternalSubscriptions::Adapter).to receive(:subscription).and_return('personal_premium')
      account.synchronize!
      expect(user.reload.plan).to eq 'personal_premium'
    end

    it 'downgrades to free when there is no live subscription' do
      allow(ExternalSubscriptions::Adapter).to receive(:subscription).and_return(nil)
      account.synchronize!
      expect(user.reload.plan).to eq 'personal_free'
    end
  end
end
