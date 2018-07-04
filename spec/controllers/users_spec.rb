require 'rails_helper'
require 'spec_helper'
require 'rspec/collection_matchers'

def setup_knock(user)
  request.headers['authorization'] = 'Bearer JWTTOKEN'
  knock = double("Knock")
  allow(knock).to receive(:entity_for).and_return(user)
  allow(Knock::AuthToken).to receive(:new).and_return(knock)
end

RSpec.describe UsersController, type: :controller do
  describe 'PATCH finished_tutorial' do
    let (:user) { FactoryGirl.create(:user, needs_tutorial: true) }
    let (:requesting_user) { nil }

    before do
      user
      requesting_user

      setup_knock(requesting_user) if requesting_user.present?
      patch :finished_tutorial, params: { user_id: user.id }
    end

    it { is_expected.to respond_with :unauthorized }

    context 'for a logged in but different requesting_user' do
      let (:requesting_user) { FactoryGirl.create(:user) }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'for a requesting user who is the acted upon user' do
      let (:requesting_user) { user }
      it { is_expected.to respond_with :ok }
      it 'should mark the tutorial complete' do
        expect(user.reload.needs_tutorial).to be false
      end
    end
  end
end
