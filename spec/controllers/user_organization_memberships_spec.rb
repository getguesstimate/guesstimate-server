require 'rails_helper'
require 'spec_helper'
require 'authentor'

def setup_knock(user)
  request.headers['authorization'] = 'Bearer JWTTOKEN'
  knock = double("Knock")
  allow(knock).to receive(:current_user).and_return(user)
  allow(knock).to receive(:validate!).and_return(true)
  allow(Knock::AuthToken).to receive(:new).and_return(knock)
end

class AuthentorMock
  def create_user(params)
    return FactoryGirl.create :user, email: params[:email], username: params[:email]
  end
end

RSpec.describe UserOrganizationMembershipsController, type: :controller do
  describe 'DELETE destroy' do
    let (:membership) { FactoryGirl.create(:user_organization_membership) }
    let (:requesting_user) { nil }
    before do
      requesting_user && setup_knock(requesting_user)
      delete :destroy, id: membership.id
    end

    shared_examples 'delete failed' do
      it { is_expected.to respond_with :unauthorized }
      it 'should not have deleted the membership' do
        expect(UserOrganizationMembership.find(membership.id)).to eq membership
      end
    end

    context 'for logged out requester' do
      include_examples 'delete failed'
    end

    context 'for admin requester' do
      let (:requesting_user) {
        user = FactoryGirl.create(:user)
        organization = membership.organization
        FactoryGirl.create(:user_organization_membership, user: user, organization: organization)
        organization.update(admin: user)
        user
      }

      it { is_expected.to respond_with :no_content }
      it 'should have deleted the membership' do
        expect { UserOrganizationMembership.find(membership.id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context 'for member (but not admin)' do
      let (:requesting_user) {
        user = FactoryGirl.create(:user)
        organization = membership.organization
        FactoryGirl.create(:user_organization_membership, user: user, organization: organization)
        user
      }
      include_examples 'delete failed'
    end

    context 'when not member' do
      let (:requesting_user) { FactoryGirl.create(:user) }
      include_examples 'delete failed'
    end
  end

  describe 'POST create_by_email' do
    let (:requesting_user) { nil }
    let (:organization) { FactoryGirl.create :organization }
    let (:existing_user) { nil }
    let (:email) { "" }

    before do
      existing_user
      requesting_user
      organization

      requesting_user && setup_knock(requesting_user)

      if existing_user.nil?
        authentor = class_double("Authentor").as_stubbed_const
        allow(authentor).to receive(:new).and_return(AuthentorMock.new())
      end

      post :create_by_email, organization_id: organization[:id], email: email
    end

    shared_examples 'successfully creates for existing user' do
      it { is_expected.to respond_with :ok }
      it 'should create the right membership' do
        expect(JSON.parse(response.body)["user_id"]).to eq existing_user.id
        expect(JSON.parse(response.body)["organization_id"]).to eq organization.id
      end
    end

    shared_examples 'authorization fails' do
      it { is_expected.to respond_with :unauthorized }
    end

    shared_examples 'creates a new auth0 user' do
      it { is_expected.to respond_with :ok }
      it 'should create the right membership' do
        expect(JSON.parse(response.body)["_embedded"]["user"]["name"]).to eq email
        expect(JSON.parse(response.body)["organization_id"]).to eq organization.id
      end
    end

    shared_context 'for existing user', user: true do
      let (:existing_user) { FactoryGirl.create :user }
      let (:email) { existing_user.email }
    end

    shared_context 'non-existent user', user: false do
      let (:existing_user) { nil }
      let (:email) { "foo@bar.com" }
    end

    context 'for visitor' do
      include_examples 'authorization fails'

      context 'for an existing user', user: true do
        include_examples 'authorization fails'
      end
    end

    context 'for logged in requester' do
      let (:requesting_user) { FactoryGirl.create :user }
      include_examples 'authorization fails'

      context 'for an existing user', user: true do
        include_examples 'authorization fails'
      end
    end

    context 'for logged in member requester' do
      let (:requesting_user) {
        user = FactoryGirl.create :user
        FactoryGirl.create :user_organization_membership, user: user, organization: organization
        user
      }

      include_examples 'authorization fails'

      context 'on existing user', user: true do
        include_examples 'authorization fails'
      end
    end

    context 'for logged in admin requester' do
      let (:requesting_user) { user = FactoryGirl.create :user }
      let (:organization) { FactoryGirl.create :organization, admin: requesting_user }

      context 'on new user', user: false do
        include_examples 'creates a new auth0 user'
      end

      context 'on existing user', user: true do
        include_examples 'successfully creates for existing user'
      end
    end
  end
end
