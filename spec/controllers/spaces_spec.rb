require 'rails_helper'
require 'spec_helper'

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
    let (:spaces) {[
      FactoryGirl.create(:space, user: creator, is_private: false, name: 'public no org'),
      FactoryGirl.create(:space, user: creator, is_private: true, name: 'private no org'),
      FactoryGirl.create(:space, organization: organization_creator_member, user: creator, is_private: true, name: 'public org'),
      FactoryGirl.create(:space, organization: organization_creator_member, user: creator, is_private: true, name: 'private org'),
      FactoryGirl.create(:space, organization: secondary_organization, user: creator, is_private: true, name: 'private org not member'),
      FactoryGirl.create(:space, user: secondary, is_private: false, name: 'public no org secondary user'),
      FactoryGirl.create(:space, user: secondary, is_private: true, name: 'private no org secondary user'),
      FactoryGirl.create(:space, organization: organization_creator_member, user: secondary, is_private: true, name: 'public org secondary user'),
      FactoryGirl.create(:space, organization: organization_creator_member, user: secondary, is_private: true, name: 'private org secondary user'),
    ]}

    let (:rendered_spaces) { JSON.parse(response.body)['items'] }

    context 'viewing user' do

      before { get :index, user_id: creator.id }

      context 'when user is logged out' do
        it { is_expected.to respond_with :ok }

        it 'should contain only the creator\'s public spaces' do
          space = FactoryGirl.create(:space, user: creator)
          expect(assigns(:spaces)).to eq 3
          expect(rendered_spaces).to eq 3
        end
      end

      context 'when user is logged in' do
        before do
          setup_knock(viewing_user)
          get :index, user_id: creator.id
        end

        context 'when user is self' do
          let (:viewing_user) { creator }
          it { is_expected.to respond_with :ok }
        end

        context 'when user is not self' do
          let (:viewing_user) { FactoryGirl.create(:user) }
          it { is_expected.to respond_with :ok }
        end
      end
    end

    context 'viewing organization' do
      before { get :index, organization_id: organization_creator_member.id }

      context 'when user is logged out' do
        it { is_expected.to respond_with :ok }
      end

      context 'when user is logged in' do
        before do
          setup_knock(viewing_user)
          get :index, organization_id: organization_creator_member.id
        end

        context 'when user is member' do
          let (:viewing_user) { creator }
          it { is_expected.to respond_with :ok }
        end

        context 'when user is not member' do
          let (:viewing_user) { FactoryGirl.create(:user) }
          it { is_expected.to respond_with :ok }
        end
      end
    end
  end
end
