require 'rails_helper'

RSpec.describe ExternalSubscriptions::Adapter do
  def entry(status, plan_id, id = 'sub_1')
    OpenStruct.new(subscription: OpenStruct.new(status: status, plan_id: plan_id, id: id))
  end

  describe '.new_subscription_hosted_page' do
    let(:result) { double(get_raw_response: { hosted_page: { id: 'hp_1' } }) }

    it 'uses checkout_new for customers without a subscription' do
      allow(ChargeBee::Subscription).to receive(:subscriptions_for_customer).and_return([])
      expect(ChargeBee::HostedPage).to receive(:checkout_new).and_return(result)
      expect(described_class.new_subscription_hosted_page(1, 'personal_lite')).to eq({ id: 'hp_1' })
    end

    it 'uses checkout_new for customers unknown to Chargebee' do
      error = ChargeBee::InvalidRequestError.new(404, OpenStruct.new(message: 'not found'))
      allow(error).to receive(:cause).and_return(OpenStruct.new(http_code: 404))
      allow(ChargeBee::Subscription).to receive(:subscriptions_for_customer).and_raise(error)
      expect(ChargeBee::HostedPage).to receive(:checkout_new).and_return(result)
      expect(described_class.new_subscription_hosted_page(1, 'personal_lite')).to eq({ id: 'hp_1' })
    end

    it 'uses checkout_existing with reactivate for a cancelled subscription' do
      allow(ChargeBee::Subscription).to receive(:subscriptions_for_customer)
        .and_return([entry('cancelled', 'personal_lite', 'sub_1')])
      expect(ChargeBee::HostedPage).to receive(:checkout_existing)
        .with(hash_including(reactivate: true, subscription: hash_including(id: 'sub_1', plan_id: 'personal_lite')))
        .and_return(result)
      expect(described_class.new_subscription_hosted_page(1, 'personal_lite')).to eq({ id: 'hp_1' })
    end

    it 'uses checkout_existing without reactivate for a live subscription' do
      allow(ChargeBee::Subscription).to receive(:subscriptions_for_customer)
        .and_return([entry('active', 'personal_lite', 'sub_1')])
      expect(ChargeBee::HostedPage).to receive(:checkout_existing)
        .with(hash_including(reactivate: false))
        .and_return(result)
      described_class.new_subscription_hosted_page(1, 'personal_premium')
    end
  end

  describe '.subscription' do
    it 'returns the plan of the first live subscription' do
      allow(ChargeBee::Subscription).to receive(:subscriptions_for_customer)
        .and_return([entry('cancelled', 'personal_premium'), entry('active', 'personal_lite')])
      expect(described_class.subscription(1)).to eq 'personal_lite'
    end

    it 'counts a non_renewing subscription as live' do
      allow(ChargeBee::Subscription).to receive(:subscriptions_for_customer)
        .and_return([entry('non_renewing', 'personal_lite')])
      expect(described_class.subscription(1)).to eq 'personal_lite'
    end

    it 'returns nil when all subscriptions are cancelled' do
      allow(ChargeBee::Subscription).to receive(:subscriptions_for_customer)
        .and_return([entry('cancelled', 'personal_lite')])
      expect(described_class.subscription(1)).to be_nil
    end
  end
end
