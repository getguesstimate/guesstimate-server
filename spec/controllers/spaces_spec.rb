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
    let (:viewcount) { nil } # default context unviewed.
    let (:is_private) { false } # default context public.
    subject (:space) { FactoryGirl.create(:space, user: owning_user, is_private: is_private, viewcount: viewcount) }

    it 'shows a public space' do
      get :show, id: space.id
      expect(response).to have_http_status :ok
    end

    context 'private space, not logged in' do
      let (:is_private) { true }
      it 'shows the private space' do
        expect(response).to have_http_status :ok
      end
    end

    context 'private space, owner logged in' do
      let (:is_private) { true }
      it 'shows the private space' do
        setup_knock(owning_user)
        get :show, id: space.id
        expect(response).to have_http_status :ok
      end
    end

    context 'private space, other user logged in' do
      let (:viewing_user) { FactoryGirl.create(:user) }
      let (:is_private) { true }
      it 'returns a 401 error' do
        setup_knock(viewing_user)
        get :show, id: space.id
        expect(response).to have_http_status 401
      end
    end
  end
end
