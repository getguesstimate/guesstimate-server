require 'rails_helper'
require 'spec_helper'

def setup_knock(user)
  request.headers['authorization'] = 'Bearer JWTTOKEN'
  knock = double("Knock")
  allow(knock).to receive(:entity_for).and_return(user)
  allow(Knock::AuthToken).to receive(:new).and_return(knock)
end

RSpec.describe UserOrganizationInvitationsController, type: :controller do
  describe 'POST invite_by_email' do
    let (:requesting_user) { nil }
    let (:organization) { FactoryGirl.create :organization }
    let (:existing_user) { nil }
    let (:email) { "" }

    before do
      existing_user
      requesting_user
      organization

      requesting_user && setup_knock(requesting_user)

      post :invite_by_email, params: { organization_id: organization[:id], email: email }
    end

    shared_examples 'successfully creates for existing user' do
      it { is_expected.to respond_with :ok }
      it 'should create the right membership' do
        expect(JSON.parse(response.body)["_embedded"]["membership"]["user_id"]).to eq existing_user.id
        expect(JSON.parse(response.body)["organization_id"]).to eq organization.id
      end
    end

    shared_examples 'authorization fails' do
      it { is_expected.to respond_with :unauthorized }
    end

    shared_examples 'invites the user' do
      it { is_expected.to respond_with :ok }
      it 'should invite the right user' do
        expect(JSON.parse(response.body)["_embeeded"]).to be nil
        expect(JSON.parse(response.body)["email"]).to eq email
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
        include_examples 'invites the user'
      end

      context 'on existing user', user: true do
        include_examples 'successfully creates for existing user'
      end
    end
  end

  describe 'GET organization_invitations' do
    let (:requesting_user) { nil }
    let (:organization) { FactoryGirl.create :organization }
    let (:secondary_organization) { FactoryGirl.create :organization }
    let (:existing_membership) { FactoryGirl.create :user_organization_membership }
    let (:invitations) {{
      in_org_no_member: FactoryGirl.create(:user_organization_invitation, organization: organization),
      in_org_member: FactoryGirl.create(:user_organization_invitation, organization: organization, membership: existing_membership),
      not_in_org: FactoryGirl.create(:user_organization_invitation, organization: secondary_organization),
    }}

    before do
      existing_membership
      requesting_user
      organization
      invitations

      requesting_user && setup_knock(requesting_user)

      get :organization_invitations, params: { organization_id: organization[:id] }
    end

    shared_examples 'authorization fails' do
      it { is_expected.to respond_with :unauthorized }
    end

    context 'for visitor' do
      include_examples 'authorization fails'
    end

    context 'for logged in requester' do
      let (:requesting_user) { FactoryGirl.create :user }
      include_examples 'authorization fails'
    end

    context 'for logged in member requester' do
      let (:requesting_user) {
        user = FactoryGirl.create :user
        FactoryGirl.create :user_organization_membership, user: user, organization: organization
        user
      }

      include_examples 'authorization fails'
    end

    context 'for logged in admin requester' do
      let (:requesting_user) { user = FactoryGirl.create :user }
      let (:organization) { FactoryGirl.create :organization, admin: requesting_user }

      let (:rendered_invitation_ids) { JSON.parse(response.body)['items'].map {|i| i['id']} }
      let (:expected_invitations) { [invitations[:in_org_no_member], invitations[:in_org_member]] }

      it { is_expected.to respond_with :ok }
      it 'should fetch the invitations' do
        expect(rendered_invitation_ids).to match_array expected_invitations.map {|i| i.id}
      end

      it 'should fetch an invitation with a membership' do
        expect(JSON.parse(response.body)['items'].any? { |invitation|
          invitation['id'] == invitations[:in_org_member].id && invitation['_embedded'].present?
        }).to be true
      end
    end
  end
end
