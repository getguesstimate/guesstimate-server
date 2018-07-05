require 'rails_helper'
require 'spec_helper'
require 'rspec/collection_matchers'

def setup_knock(user)
  request.headers['authorization'] = 'Bearer JWTTOKEN'
  knock = double('Knock')
  allow(knock).to receive(:entity_for).and_return(user)
  allow(Knock::AuthToken).to receive(:new).and_return(knock)
end

RSpec.describe FactsController, type: :controller do
  describe 'POST create' do
    let (:api_token) { nil }
    let (:passed_token) { nil }
    let (:organization) { FactoryBot.create(:organization, api_token: api_token, api_enabled: api_token.present?) }

    let (:fact_params) {{
      name: 'name',
      expression: '100',
      variable_name: 'var_1',
      simulation: {
        'sample' => {'values' => [100], 'errors' => []},
        'stats' => {'mean' => 100, 'stdev' => 0, 'length' => 1}
      }
    }}

    shared_examples 'it successfully creates the fact' do
      it 'should successfully create the fact' do
        expect(subject).to respond_with :ok
        expect(JSON.parse(response.body)['name']).to eq fact_params[:name]
        expect(JSON.parse(response.body)['expression']).to eq fact_params[:expression]
        expect(JSON.parse(response.body)['variable_name']).to eq fact_params[:variable_name]
        expect(JSON.parse(response.body)['organization_id']).to eq organization.id
      end
    end

    let (:creating_user) { nil }
    before do
      setup_knock(creating_user) if creating_user.present?
      request.headers['Api-Token'] = passed_token if passed_token.present?
      post :create, params: { fact: fact_params, organization_id: organization.id }
    end

    context 'for a logged out creator' do
      context 'with no token' do
        it { is_expected.to respond_with :unauthorized }
      end

      context 'with a token' do
        let (:api_token) { 'a'*32 }

        context 'with no passed token' do
          it { is_expected.to respond_with :unauthorized }
        end

        context 'with an incorrect passed token' do
          let (:passed_token) { 'incorrect' }
          it { is_expected.to respond_with :unauthorized }
        end

        context 'with a correct passed token' do
          let (:passed_token) { api_token }
          include_examples 'it successfully creates the fact'
        end
      end
    end

    context 'for a logged-in, non-member creator' do
      let (:creating_user) { FactoryBot.create(:user) }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'for a logged-in, member creator' do
      let (:creating_user) {
        user = FactoryBot.create(:user)
        FactoryBot.create(:user_organization_membership, user: user, organization: organization)
        user
      }
      include_examples 'it successfully creates the fact'
    end
  end

  describe 'PATCH update' do
    let (:fact) { FactoryBot.create(:fact) }
    let (:author) {
      user = FactoryBot.create(:user)
      FactoryBot.create(:user_organization_membership, user: user, organization: fact.organization)
      user
    }
    let (:fact_params) {{
      name: 'name',
      expression: '100',
      variable_name: 'var_1',
      simulation: {
        'sample' => {'values' => [100], 'errors' => []},
        'stats' => {'mean' => 100, 'stdev' => 0, 'length' => 1}
      }
    }}

    before do
      setup_knock(author)
    end

    it 'should successfully update the fact' do
      patch :update, params: { fact: fact_params, organization_id: fact.organization.id, id: fact.id }

      expect(subject).to respond_with :ok
      expect(JSON.parse(response.body)['name']).to eq fact_params[:name]
      expect(JSON.parse(response.body)['expression']).to eq fact_params[:expression]
      expect(JSON.parse(response.body)['variable_name']).to eq fact_params[:variable_name]
      expect(JSON.parse(response.body)['organization_id']).to eq fact.organization.id
    end

    it 'should successfully take a checkpoint' do
      # It should start with no checkpoints
      expect(fact.checkpoints.count).to be 0

      patch :update, params: { fact: fact_params, organization_id: fact.organization.id, id: fact.id }

      # Now it should have a checkpoint
      expect(fact.checkpoints.count).to be 1
    end
  end
end
