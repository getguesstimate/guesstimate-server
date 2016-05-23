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
    let (:owning_user) { FactoryGirl.create(:user, :lite_plan) }
    let (:is_private) { false } # default context public.
    let (:space) { FactoryGirl.create(:space, user: owning_user, is_private: is_private) }

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
        let (:viewing_user) { owning_user }

        it { is_expected.to respond_with :ok }

        context 'when space is private' do
          let (:is_private) { true }
          it { is_expected.to respond_with :ok }
        end
      end
    end
  end
end
