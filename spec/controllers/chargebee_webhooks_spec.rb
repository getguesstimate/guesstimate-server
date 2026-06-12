require 'rails_helper'

RSpec.describe ChargebeeWebhooksController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:event_params) {
    { event_type: 'subscription_cancelled', content: { customer: { id: user.id.to_s } } }
  }

  def authenticate!
    request.env['HTTP_AUTHORIZATION'] =
      ActionController::HttpAuthentication::Basic.encode_credentials('chargebee', 'test-webhook-password')
  end

  describe '#create' do
    it 'rejects requests without credentials' do
      post :create, params: event_params
      expect(response.status).to eq 401
    end

    it 'rejects requests with wrong credentials' do
      request.env['HTTP_AUTHORIZATION'] =
        ActionController::HttpAuthentication::Basic.encode_credentials('chargebee', 'wrong')
      post :create, params: event_params
      expect(response.status).to eq 401
    end

    it 'synchronizes the user account named by content.customer.id' do
      authenticate!
      expect_any_instance_of(UserAccount).to receive(:synchronize!)
      post :create, params: event_params
      expect(response.status).to eq 200
    end

    it 'falls back to content.subscription.customer_id' do
      authenticate!
      expect_any_instance_of(UserAccount).to receive(:synchronize!)
      post :create, params: {
        event_type: 'subscription_changed',
        content: { subscription: { customer_id: user.id.to_s } }
      }
      expect(response.status).to eq 200
    end

    it 'returns 200 for events about unknown customers' do
      authenticate!
      post :create, params: {
        event_type: 'subscription_created',
        content: { customer: { id: 'cfgprobe_guesstimate' } }
      }
      expect(response.status).to eq 200
    end
  end
end
