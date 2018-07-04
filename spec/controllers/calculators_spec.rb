require 'rails_helper'
require 'spec_helper'
require 'rspec/collection_matchers'

def setup_knock(user)
  request.headers['authorization'] = 'Bearer JWTTOKEN'
  knock = double("Knock")
  allow(knock).to receive(:entity_for).and_return(user)
  allow(Knock::AuthToken).to receive(:new).and_return(knock)
end

RSpec.describe CalculatorsController, type: :controller do
  describe 'POST create' do
    let (:creator) { FactoryGirl.create(:user, :lite_plan) }
    let (:is_private) { false } # default context public.
    let (:organization) { nil } # default context no organization.
    let (:space) { FactoryGirl.create(:space, user: creator, organization: organization, is_private: is_private) }

    let (:calculator_params) {{
      title: 'title',
      content: 'content',
      input_ids: ['1'],
      output_ids: ['2']
    }}

    shared_examples 'it successfully creates the calculator' do
      it 'should successfully create the calculator' do
        expect(JSON.parse(response.body)['title']).to eq calculator_params[:title]
        expect(JSON.parse(response.body)['content']).to eq calculator_params[:content]
        expect(JSON.parse(response.body)['input_ids']).to eq calculator_params[:input_ids]
        expect(JSON.parse(response.body)['output_ids']).to eq calculator_params[:output_ids]
        expect(subject).to respond_with :ok
      end
    end

    let (:viewing_user) { nil }
    before do
      setup_knock(viewing_user) if viewing_user.present?
      post :create, space_id: space.id, calculator: calculator_params
    end

    context 'for a logged out creator' do
      it { is_expected.to respond_with :unauthorized }
    end

    context 'for a logged in creator' do
      let (:viewing_user) { FactoryGirl.create(:user) }

      it { is_expected.to respond_with :unauthorized }

      context 'for a creator who also owns the underlying space' do
        let (:viewing_user) { creator }
        include_examples 'it successfully creates the calculator'

        context 'for a private space' do
          let (:is_private) { true }

          context 'for a space without organization' do
            include_examples 'it successfully creates the calculator'
          end

          context 'for a space with organization' do
            context 'for a creator who is a member' do
              let (:organization) {
                organization = FactoryGirl.create(:organization)
                FactoryGirl.create(:user_organization_membership, user: creator, organization: organization)
                organization
              }
              include_examples 'it successfully creates the calculator'
            end

            context 'for a non-membered creator' do
              let (:organization) { FactoryGirl.create(:organization) }
              it { is_expected.to respond_with :unauthorized }
            end
          end
        end
      end
    end
  end
end
