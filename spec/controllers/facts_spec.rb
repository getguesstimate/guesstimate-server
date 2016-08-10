require 'rails_helper'
require 'spec_helper'
require 'rspec/collection_matchers'

def setup_knock(user)
  request.headers['authorization'] = 'Bearer JWTTOKEN'
  knock = double("Knock")
  allow(knock).to receive(:current_user).and_return(user)
  allow(knock).to receive(:validate!).and_return(true)
  allow(Knock::AuthToken).to receive(:new).and_return(knock)
end

RSpec.describe FactsController, type: :controller do
  describe 'POST create' do
    let (:organization) { FactoryGirl.create(:organization) }

    let (:fact_params) {{
      name: 'name',
      expression: '100',
      variable_name: 'var_1',
      simulation: {
        "sample" => {"values" => [100], "errors" => []},
        "stats" => {"mean" => 100, "stdev" => 0, "length" => 0}
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
      post :create, fact: fact_params, organization_id: organization.id
    end

    context 'for a logged out creator' do
      it { is_expected.to respond_with :unauthorized }
    end

    context 'for a logged-in, non-member creator' do
      let (:creating_user) { FactoryGirl.create(:user) }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'for a logged-in, member creator' do
      let (:creating_user) {
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:user_organization_membership, user: user, organization: organization)
        user
      }
      include_examples 'it successfully creates the fact'
    end
  end

  describe 'PATCH update' do
    let (:fact) { FactoryGirl.create(:fact) }
    let (:author) {
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:user_organization_membership, user: user, organization: fact.organization)
      user
    }
    let (:fact_params) {{
      name: 'name',
      expression: '100',
      variable_name: 'var_1',
      simulation: {
        "sample" => {"values" => [100], "errors" => []},
        "stats" => {"mean" => 100, "stdev" => 0, "length" => 0}
      }
    }}

    before do
      setup_knock(author)
    end

    it 'should successfully update the fact' do
      patch :update, fact: fact_params, organization_id: fact.organization.id, id: fact.id

      expect(subject).to respond_with :ok
      expect(JSON.parse(response.body)['name']).to eq fact_params[:name]
      expect(JSON.parse(response.body)['expression']).to eq fact_params[:expression]
      expect(JSON.parse(response.body)['variable_name']).to eq fact_params[:variable_name]
      expect(JSON.parse(response.body)['organization_id']).to eq fact.organization.id
    end

    it 'should successfully take a checkpoint' do
      # It should start with no checkpoints
      expect(fact.checkpoints.count).to be 0

      patch :update, fact: fact_params, organization_id: fact.organization.id, id: fact.id

      # Now it should have a checkpoint
      expect(fact.checkpoints.count).to be 1
    end
  end
end
