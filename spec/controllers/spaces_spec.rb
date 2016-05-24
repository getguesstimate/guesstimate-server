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

RSpec.describe SpacesController, type: :controller do
  describe 'GET show' do
    let (:creator) { FactoryGirl.create(:user, :lite_plan) }
    let (:is_private) { false } # default context public.
    let (:organization) { nil } # default context no organization.
    let (:space) { FactoryGirl.create(:space, user: creator, organization: organization, is_private: is_private) }

    context 'when user is logged out' do
      before { get :show, id: space.id }

      it { is_expected.to respond_with :ok }

      context 'when space is private' do
        let (:is_private) { true }
        it { is_expected.to respond_with :unauthorized }
      end
    end

    context 'when user is logged in' do
      let (:viewing_user) { FactoryGirl.create(:user) }

      before do
        setup_knock(viewing_user)
        get :show, id: space.id
      end

      it { is_expected.to respond_with :ok }

      context 'when space is private' do
        let (:is_private) { true }
        it { is_expected.to respond_with :unauthorized }
      end

      context 'when viewer is owner' do
        let (:viewing_user) { creator }

        it { is_expected.to respond_with :ok }

        context 'when space is private' do
          let (:is_private) { true }

          context 'when space does not have organization' do
            it { is_expected.to respond_with :ok }
          end

          context 'when space has organization' do
            context 'when creator is member' do
              let (:organization) {
                organization = FactoryGirl.create(:organization)
                FactoryGirl.create(:user_organization_membership, user: creator, organization: organization)
                organization
              }
              it { is_expected.to respond_with :ok }
            end

            context 'when creator is not member' do
              let (:organization) { FactoryGirl.create(:organization) }
              it { is_expected.to respond_with :unauthorized }
            end
          end
        end
      end
    end
  end

  describe 'GET index' do
    let (:creator) { FactoryGirl.create(:user, :lite_plan) }
    let (:secondary) { FactoryGirl.create(:user, :lite_plan) }
    let (:organization_creator_member) {
      organization = FactoryGirl.create(:organization, name: 'creator member')
      FactoryGirl.create(:user_organization_membership, user: creator, organization: organization)
      organization
    }
    let (:secondary_organization) { FactoryGirl.create(:organization, name: 'creator not member') }
    let (:spaces) {{
      creator_public_no_org: FactoryGirl.create(:space, user: creator, is_private: false, name: 'public no org'),
      creator_private_no_org: FactoryGirl.create(:space, user: creator, is_private: true, name: 'private no org'),
      creator_public_org: FactoryGirl.create(:space, organization: organization_creator_member, user: creator, is_private: false, name: 'public org'),
      creator_private_org: FactoryGirl.create(:space, organization: organization_creator_member, user: creator, is_private: true, name: 'private org'),
      creator_public_org_no_member: FactoryGirl.create(:space, organization: secondary_organization, user: creator, is_private: false, name: 'private org not member'),
      creator_private_org_no_member: FactoryGirl.create(:space, organization: secondary_organization, user: creator, is_private: true, name: 'private org not member'),
      secondary_public_no_org: FactoryGirl.create(:space, user: secondary, is_private: false, name: 'public no org secondary user'),
      secondary_private_no_org: FactoryGirl.create(:space, user: secondary, is_private: true, name: 'private no org secondary user'),
      secondary_public_org: FactoryGirl.create(:space, organization: organization_creator_member, user: secondary, is_private: false, name: 'public org secondary user'),
      secondary_private_org: FactoryGirl.create(:space, organization: organization_creator_member, user: secondary, is_private: true, name: 'private org secondary user'),
    }}

    #TODO(matthew): I want to just parse this via the spaces representer but that seems impossible.
    #let (:rendered_spaces) { SpacesRepresenter.new([]).from_json(response.body) }
    let (:rendered_space_ids) { JSON.parse(response.body)['items'].map {|s| s['id']} }
    let (:viewing_user) { nil }

    before do
      spaces
      viewing_user && setup_knock(viewing_user)
      get :index, get_params
    end

    shared_examples 'has_visible_spaces' do
      it { is_expected.to respond_with :ok }
      it 'has correct spaces' do
        expect(rendered_space_ids).to match_array(expected_rendered_spaces.map{|e| spaces[e][:id]})
      end
    end

    context 'viewing user' do
      let (:get_params) {{user_id: creator.id}}

      context 'when viewer is logged out' do
        let (:expected_rendered_spaces) { [:creator_public_org, :creator_public_no_org, :creator_public_org_no_member] }
        include_examples 'has_visible_spaces'
      end

      context 'when viewer is owner' do
        let (:viewing_user) { creator }
        let (:expected_rendered_spaces) {[
          :creator_public_org,
          :creator_public_no_org,
          :creator_private_org,
          :creator_private_no_org,
        ]}
        include_examples 'has_visible_spaces'
      end

      context 'when viewer is not owner' do
        let (:viewing_user) { FactoryGirl.create(:user) }
        let (:expected_rendered_spaces) {[
          :creator_public_org,
          :creator_public_no_org,
          :creator_public_org_no_member,
        ]}
        include_examples 'has_visible_spaces'
      end
    end

    context 'viewing organization' do
      let (:get_params) {{organization_id: organization_creator_member.id}}

      context 'when viewer is logged out' do
        let (:expected_rendered_spaces) {[:creator_public_org, :secondary_public_org]}
        include_examples 'has_visible_spaces'
      end

      context 'when viewer is member' do
        let (:viewing_user) { creator }
        let (:expected_rendered_spaces) {[
          :creator_public_org,
          :creator_private_org,
          :secondary_public_org,
          :secondary_private_org,
        ]}
        include_examples 'has_visible_spaces'
      end

      context 'when viewer is not member' do
        let (:viewing_user) { FactoryGirl.create(:user) }
        let (:expected_rendered_spaces) {[:creator_public_org, :secondary_public_org]}
        include_examples 'has_visible_spaces'
      end
    end
  end
end
