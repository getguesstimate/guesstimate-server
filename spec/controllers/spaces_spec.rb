require 'rails_helper'
require 'rspec/collection_matchers'

def setup_knock(user)
  request.headers['authorization'] = 'Bearer JWTTOKEN'
  knock = double("Knock")
  allow(knock).to receive(:entity_for).and_return(user)
  allow(Knock::AuthToken).to receive(:new).and_return(knock)
end

RSpec.describe SpacesController, type: :controller do
  describe 'GET show' do
    let (:creator) { FactoryBot.create(:user, :lite_plan) }
    let (:is_private) { false } # default context public.
    let (:organization) { nil } # default context no organization.
    let (:shareable_link_token) { nil }
    let (:shareable_link_enabled) { false }
    let (:space) {
      FactoryBot.create(
        :space,
        user: creator,
        organization: organization,
        is_private: is_private,
        shareable_link_enabled: shareable_link_enabled && shareable_link_token.present?,
        shareable_link_token: shareable_link_token,
      )
    }

    context 'with shareable link disabled' do
      context 'with token in params' do
        let (:shareable_link_token) { 'a' * 32 }
        before {
          request.headers['Shareable-Link-Token'] = shareable_link_token
          get :show, params: { id: space.id }
        }

        it { is_expected.to respond_with :ok }

        context 'for a private space' do
          let (:is_private) { true }
          it { is_expected.to respond_with :unauthorized }
        end
      end

      context 'for a logged out viewer' do
        before { get :show, params: { id: space.id } }

        it { is_expected.to respond_with :ok }

        context 'for a private space' do
          let (:is_private) { true }
          it { is_expected.to respond_with :unauthorized }
        end
      end

      context 'for a logged in viewer' do
        let (:viewing_user) { FactoryBot.create(:user) }

        before do
          setup_knock(viewing_user)
          get :show, params: { id: space.id }
        end

        it { is_expected.to respond_with :ok }

        context 'for a private space' do
          let (:is_private) { true }
          it { is_expected.to respond_with :unauthorized }
        end

        context 'for a viewing creator' do
          let (:viewing_user) { creator }

          it { is_expected.to respond_with :ok }

          context 'for a private space' do
            let (:is_private) { true }

            context 'for a space without organization' do
              it { is_expected.to respond_with :ok }
            end

            context 'for a space with organization' do
              context 'for a creator who is a member' do
                let (:organization) {
                  organization = FactoryBot.create(:organization)
                  FactoryBot.create(:user_organization_membership, user: creator, organization: organization)
                  organization
                }
                it { is_expected.to respond_with :ok }
              end

              context 'for a non-membered creator' do
                let (:organization) { FactoryBot.create(:organization) }
                it { is_expected.to respond_with :unauthorized }
              end
            end
          end
        end
      end
    end

    context 'with shareable link enabled, logged out viewer, on a private space' do
      let (:is_private) { true }
      let (:shareable_link_enabled) { true }
      let (:shareable_link_token) { 'a' * 32 }
      let (:params_token) { nil }
      before {
        request.headers['Shareable-Link-Token'] = params_token
        get :show, params: { id: space.id }
      }

      context 'with no token in params' do
        it { is_expected.to respond_with :unauthorized }
      end

      context 'with token in params' do
        context 'with invalid token' do
          let (:params_token) { 'b' * 32 }
          it { is_expected.to respond_with :unauthorized }
        end

        context 'with valid token' do
          let (:params_token) { shareable_link_token }
          it { is_expected.to respond_with :ok }
        end
      end
    end
  end

  describe 'GET index' do
    let (:creator) { FactoryBot.create(:user, :lite_plan) }
    let (:secondary) { FactoryBot.create(:user, :lite_plan) }
    let (:organization_creator_member) {
      organization = FactoryBot.create(:organization, name: 'creator member')
      FactoryBot.create(:user_organization_membership, user: creator, organization: organization)
      organization
    }
    let (:secondary_organization) { FactoryBot.create(:organization, name: 'creator not member') }
    let (:spaces) {{
      creator_public_no_org: FactoryBot.create(:space, user: creator, is_private: false, name: 'public no org'),
      creator_private_no_org: FactoryBot.create(:space, user: creator, is_private: true, name: 'private no org'),
      creator_public_org: FactoryBot.create(:space, organization: organization_creator_member, user: creator, is_private: false, name: 'public org'),
      creator_private_org: FactoryBot.create(:space, organization: organization_creator_member, user: creator, is_private: true, name: 'private org'),
      creator_public_org_no_member: FactoryBot.create(:space, organization: secondary_organization, user: creator, is_private: false, name: 'private org not member'),
      creator_private_org_no_member: FactoryBot.create(:space, organization: secondary_organization, user: creator, is_private: true, name: 'private org not member'),
      secondary_public_no_org: FactoryBot.create(:space, user: secondary, is_private: false, name: 'public no org secondary user'),
      secondary_private_no_org: FactoryBot.create(:space, user: secondary, is_private: true, name: 'private no org secondary user'),
      secondary_public_org: FactoryBot.create(:space, organization: organization_creator_member, user: secondary, is_private: false, name: 'public org secondary user'),
      secondary_private_org: FactoryBot.create(:space, organization: organization_creator_member, user: secondary, is_private: true, name: 'private org secondary user'),
    }}

    let (:rendered_space_ids) { JSON.parse(response.body)['items'].map {|s| s['id']} }
    let (:viewing_user) { nil }

    before do
      spaces
      viewing_user && setup_knock(viewing_user)
      get :index, params: get_params
    end

    shared_examples 'has_visible_spaces' do
      it { is_expected.to respond_with :ok }
      it 'has correct spaces' do
        expect(rendered_space_ids).to match_array(expected_rendered_spaces.map{|e| spaces[e][:id]})
      end
    end

    context 'viewing user' do
      let (:get_params) {{user_id: creator.id}}

      context 'for a logged out viewer' do
        let (:expected_rendered_spaces) { [:creator_public_org, :creator_public_no_org, :creator_public_org_no_member] }
        include_examples 'has_visible_spaces'
      end

      context 'for a viewing creator' do
        let (:viewing_user) { creator }
        let (:expected_rendered_spaces) {[
          :creator_public_org,
          :creator_public_no_org,
          :creator_private_org,
          :creator_private_no_org,
        ]}
        include_examples 'has_visible_spaces'
      end

      context 'for a logged in viewer (not creator)' do
        let (:viewing_user) { FactoryBot.create(:user) }
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

      context 'for a logged out viewer' do
        let (:expected_rendered_spaces) {[:creator_public_org, :secondary_public_org]}
        include_examples 'has_visible_spaces'
      end

      context 'for a viewing member' do
        let (:viewing_user) { creator }
        let (:expected_rendered_spaces) {[
          :creator_public_org,
          :creator_private_org,
          :secondary_public_org,
          :secondary_private_org,
        ]}
        include_examples 'has_visible_spaces'
      end

      context 'for a viewer who is not a member' do
        let (:viewing_user) { FactoryBot.create(:user) }
        let (:expected_rendered_spaces) {[:creator_public_org, :secondary_public_org]}
        include_examples 'has_visible_spaces'
      end
    end
  end

  describe 'PATCH enable_shareable_link' do
    # Server Variables:
    let (:creator) { FactoryBot.create(:user) }
    let (:organization) { nil }
    let (:is_private) { false }
    let (:shareable_link_enabled) { false }
    let (:shareable_link_token) { nil }
    let (:space) {
      FactoryBot.create(
        :space,
        user: creator,
        organization: organization,
        is_private: is_private,
        shareable_link_enabled: shareable_link_enabled && shareable_link_token.present?,
        shareable_link_token: shareable_link_token,
      )
    }

    # Client Variables:
    let (:viewing_user) { nil }

    # Shared Contextes:
    shared_context 'private space', is_private: true do
      let (:creator) { FactoryBot.create(:user, :lite_plan) }
      let (:is_private) { true }
    end
    shared_context 'public space', is_private: false do
      let (:is_private) { false }
    end

    shared_context 'shareable_link enabled', space_shareable_link_enabled: true do
      include_context 'private space'
      let (:shareable_link_enabled) { true }
      let (:shareable_link_token) { 'a' * 32 }
    end
    shared_context 'shareable_link disabled', space_shareable_link_enabled: false do
      let (:shareable_link_enabled) { false }
      let (:shareable_link_token) { nil }
    end

    # Shared Examples:
    shared_examples 'responds with enabled shareable_link' do
      it { is_expected.to respond_with :ok }

      it 'renders a space with shareable_link enabled' do
        rendered_space = SpaceRepresenter.new(Space.new).from_json response.body, user_options: {current_user_can_edit: true}

        expect(rendered_space.shareable_link_enabled).to be true

        if shareable_link_token.present?
          expect(rendered_space.shareable_link_token).to eq shareable_link_token
        else
          expect(rendered_space.shareable_link_token).to be_truthy
          expect(rendered_space.shareable_link_token.length).to be > 32
        end
      end
    end

    before do
      space
      viewing_user

      setup_knock(viewing_user) if viewing_user.present?
      patch :enable_shareable_link, params: { id: space.id }
    end

    context 'logged out viewer' do
      let (:viewing_user) { nil }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'logged in viewer who is not creator' do
      let (:viewing_user) { FactoryBot.create(:user) }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'viewer is also creator' do
      let (:viewing_user) { creator }

      context 'on a public space', is_private: false do
        it { is_expected.to respond_with :unprocessable_entity }
      end

      context 'with shareable_link disabled on a private space', space_shareable_link_enabled: false, is_private: true do
        include_examples 'responds with enabled shareable_link'
      end

      context 'with shareable_link enabled on a private space', space_shareable_link_enabled: true do
        include_examples 'responds with enabled shareable_link'
      end
    end

    context 'space has organization' do
      let (:organization) { FactoryBot.create(:organization) }

      context 'viewer is not a member' do
        let (:viewing_user) { FactoryBot.create(:user) }
        it { is_expected.to respond_with :unauthorized }
      end

      context 'viewer is a member' do
        let (:viewing_user) do
          user = FactoryBot.create(:user)
          FactoryBot.create(:user_organization_membership, user: user, organization: organization)
          user
        end

        context 'on a public space', is_private: false do
          it { is_expected.to respond_with :unprocessable_entity }
        end

        context 'with shareable_link disabled on a private space', space_shareable_link_enabled: false, is_private: true do
          include_examples 'responds with enabled shareable_link'
        end

        context 'with shareable_link enabled on a private space', space_shareable_link_enabled: true do
          include_examples 'responds with enabled shareable_link'
        end
      end
    end
  end

  describe 'PATCH disable_shareable_link' do
    # Server Variables:
    let (:creator) { FactoryBot.create(:user) }
    let (:organization) { nil }
    let (:is_private) { false }
    let (:shareable_link_enabled) { false }
    let (:shareable_link_token) { nil }
    let (:space) {
      FactoryBot.create(
        :space,
        user: creator,
        organization: organization,
        is_private: is_private,
        shareable_link_enabled: shareable_link_enabled && shareable_link_token.present?,
        shareable_link_token: shareable_link_token,
      )
    }

    # Client Variables:
    let (:viewing_user) { nil }

    # Shared Contextes:
    shared_context 'private space', is_private: true do
      let (:creator) { FactoryBot.create(:user, :lite_plan) }
      let (:is_private) { true }
    end
    shared_context 'public space', is_private: false do
      let (:is_private) { false }
    end

    shared_context 'shareable_link enabled', space_shareable_link_enabled: true do
      include_context 'private space'
      let (:shareable_link_enabled) { true }
      let (:shareable_link_token) { 'a' * 32 }
    end
    shared_context 'shareable_link disabled', space_shareable_link_enabled: false do
      let (:shareable_link_enabled) { false }
      let (:shareable_link_token) { nil }
    end

    # Shared Examples:
    shared_examples 'responds with disabled shareable_link' do
      it { is_expected.to respond_with :ok }

      it 'renders a space with shareable_link disabled' do
        rendered_space = SpaceRepresenter.new(Space.new).from_json response.body, user_options: {current_user_can_edit: true}

        expect(rendered_space.shareable_link_enabled).to be false
        expect(rendered_space.shareable_link_token).to be_nil
      end
    end

    before do
      space
      viewing_user

      setup_knock(viewing_user) if viewing_user.present?
      patch :disable_shareable_link, params: { id: space.id }
    end

    context 'logged out viewer' do
      let (:viewing_user) { nil }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'logged in viewer who is not creator' do
      let (:viewing_user) { FactoryBot.create(:user) }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'viewer is also creator' do
      let (:viewing_user) { creator }

      context 'on a public space', is_private: false do
        include_examples 'responds with disabled shareable_link'
      end

      context 'with shareable_link disabled on a private space', space_shareable_link_enabled: false, is_private: true do
        include_examples 'responds with disabled shareable_link'
      end

      context 'with shareable_link enabled on a private space', space_shareable_link_enabled: true do
        include_examples 'responds with disabled shareable_link'
      end
    end

    context 'space has organization' do
      let (:organization) { FactoryBot.create(:organization) }

      context 'viewer is not a member' do
        let (:viewing_user) { FactoryBot.create(:user) }
        it { is_expected.to respond_with :unauthorized }
      end

      context 'viewer is a member' do
        let (:viewing_user) do
          user = FactoryBot.create(:user)
          FactoryBot.create(:user_organization_membership, user: user, organization: organization)
          user
        end

        context 'on a public space', is_private: false do
          include_examples 'responds with disabled shareable_link'
        end

        context 'with shareable_link disabled on a private space', space_shareable_link_enabled: false, is_private: true do
          include_examples 'responds with disabled shareable_link'
        end

        context 'with shareable_link enabled on a private space', space_shareable_link_enabled: true do
          include_examples 'responds with disabled shareable_link'
        end
      end
    end
  end

  describe 'PATCH rotate_shareable_link' do
    # Server Variables:
    let (:creator) { FactoryBot.create(:user) }
    let (:organization) { nil }
    let (:is_private) { false }
    let (:shareable_link_enabled) { false }
    let (:shareable_link_token) { nil }
    let (:space) {
      FactoryBot.create(
        :space,
        user: creator,
        organization: organization,
        is_private: is_private,
        shareable_link_enabled: shareable_link_enabled && shareable_link_token.present?,
        shareable_link_token: shareable_link_token,
      )
    }

    # Client Variables:
    let (:viewing_user) { nil }

    # Shared Contextes:
    shared_context 'private space', is_private: true do
      let (:creator) { FactoryBot.create(:user, :lite_plan) }
      let (:is_private) { true }
    end
    shared_context 'public space', is_private: false do
      let (:is_private) { false }
    end

    shared_context 'shareable_link enabled', space_shareable_link_enabled: true do
      include_context 'private space'

      let (:shareable_link_enabled) { true }
      let (:shareable_link_token) { 'a' * 32 }
    end
    shared_context 'shareable_link disabled', space_shareable_link_enabled: false do
      let (:shareable_link_enabled) { false }
      let (:shareable_link_token) { nil }
    end

    # Shared Examples:
    shared_examples 'responds with rotated shareable_link' do
      it { is_expected.to respond_with :ok }

      it 'renders a space with shareable_link rotated' do
        rendered_space = SpaceRepresenter.new(Space.new).from_json response.body, user_options: {current_user_can_edit: true}

        expect(rendered_space.shareable_link_enabled).to be true

        if shareable_link_token.present?
          expect(rendered_space.shareable_link_token).to be_truthy
          expect(rendered_space.shareable_link_token.length).to be > 20
          expect(rendered_space.shareable_link_token).not_to eq shareable_link_token
        end
      end
    end

    before do
      space
      viewing_user

      setup_knock(viewing_user) if viewing_user.present?
      patch :rotate_shareable_link, params: { id: space.id }
    end

    context 'logged out viewer' do
      let (:viewing_user) { nil }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'logged in viewer who is not creator' do
      let (:viewing_user) { FactoryBot.create(:user) }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'viewer is also creator' do
      let (:viewing_user) { creator }

      context 'with shareable_link disabled on a private space', space_shareable_link_enabled: false, is_private: true do
        it { is_expected.to respond_with :unprocessable_entity }
      end

      context 'with shareable_link enabled on a private space', space_shareable_link_enabled: true do
        include_examples 'responds with rotated shareable_link'
      end
    end

    context 'space has organization' do
      let (:organization) { FactoryBot.create(:organization) }

      context 'viewer is not a member' do
        let (:viewing_user) { FactoryBot.create(:user) }
        it { is_expected.to respond_with :unauthorized }
      end

      context 'viewer is a member' do
        let (:viewing_user) do
          user = FactoryBot.create(:user)
          FactoryBot.create(:user_organization_membership, user: user, organization: organization)
          user
        end

        context 'with shareable_link disabled on a private space', space_shareable_link_enabled: false, is_private: true do
          it { is_expected.to respond_with :unprocessable_entity }
        end

        context 'with shareable_link enabled on a private space', space_shareable_link_enabled: true do
          include_examples 'responds with rotated shareable_link'
        end
      end
    end
  end
end
