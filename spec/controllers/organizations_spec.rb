require 'rails_helper'
require 'spec_helper'
require 'rspec/collection_matchers'

def setup_knock(user)
  request.headers['authorization'] = 'Bearer JWTTOKEN'
  knock = double("Knock")
  allow(knock).to receive(:entity_for).and_return(user)
  allow(Knock::AuthToken).to receive(:new).and_return(knock)
end

RSpec.describe OrganizationsController, type: :controller do
  describe 'PATCH enable_api_access' do
    # Server Variables:
    let (:admin) { FactoryBot.create(:user) }
    let (:api_enabled) { false }
    let (:api_token) { nil }
    let (:organization) { FactoryBot.create(:organization, api_enabled: api_enabled, api_token: api_token, admin: admin) }

    # Client Variables:
    let (:viewing_user) { nil }

    # Shared Contextes:
    shared_context 'api enabled', organization_api_enabled: true do
      let (:api_enabled) { true }
      let (:api_token) { 'a' * 32 }
    end
    shared_context 'api disabled', organization_api_enabled: false do
      let (:api_enabled) { false }
      let (:api_token) { nil }
    end

    # Shared Examples:
    shared_examples 'responds with enabled api' do
      it { is_expected.to respond_with :ok }

      it 'renders an organization with api enabled' do
        rendered_body = JSON.parse(response.body)
        rendered_token = rendered_body['api_token']
        rendered_api_enabled = rendered_body['api_enabled']

        expect(rendered_api_enabled).to be true

        expect(rendered_token).to be_truthy
        expect(rendered_token.length).to be >= 32

        expect(rendered_token).to eq api_token if api_token.present?
      end
    end

    before do
      organization
      viewing_user

      setup_knock(viewing_user) if viewing_user.present?
      patch :enable_api_access, params: { id: organization.id }
    end

    context 'logged out viewer' do
      let (:viewing_user) { nil }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'logged in viewer who is not member, not admin' do
      let (:viewing_user) { FactoryBot.create(:user) }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'logged in viewer who is member, not admin' do
      let (:viewing_user) {
        user = FactoryBot.create(:user)
        FactoryBot.create(:user_organization_membership, user: user, organization: organization)
        user
      }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'viewer is also admin' do
      let (:viewing_user) { admin }
      context 'disabled_api', organization_api_enabled: false do
        include_examples 'responds with enabled api'
      end

      context 'enabled_api', organization_api_enabled: true do
        include_examples 'responds with enabled api'
      end
    end
  end

  describe 'PATCH disable_api_access' do
    # Server Variables:
    let (:admin) { FactoryBot.create(:user) }
    let (:api_enabled) { false }
    let (:api_token) { nil }
    let (:organization) { FactoryBot.create(:organization, api_enabled: api_enabled, api_token: api_token, admin: admin) }

    # Client Variables:
    let (:viewing_user) { nil }

    # Shared Contextes:
    shared_context 'api enabled', organization_api_enabled: true do
      let (:api_enabled) { true }
      let (:api_token) { 'a' * 32 }
    end
    shared_context 'api disabled', organization_api_enabled: false do
      let (:api_enabled) { false }
      let (:api_token) { nil }
    end

    # Shared Examples:
    shared_examples 'responds with disabled api' do
      it { is_expected.to respond_with :ok }

      it 'renders an organization with api enabled' do
        rendered_body = JSON.parse(response.body)
        rendered_token = rendered_body['api_token']
        rendered_api_enabled = rendered_body['api_enabled']

        expect(rendered_api_enabled).to be_falsey

        expect(rendered_token).to be_nil
      end
    end

    before do
      organization
      viewing_user

      setup_knock(viewing_user) if viewing_user.present?
      patch :disable_api_access, params: { id: organization.id }
    end

    context 'logged out viewer' do
      let (:viewing_user) { nil }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'logged in viewer who is not member, not admin' do
      let (:viewing_user) { FactoryBot.create(:user) }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'logged in viewer who is member, not admin' do
      let (:viewing_user) {
        user = FactoryBot.create(:user)
        FactoryBot.create(:user_organization_membership, user: user, organization: organization)
        user
      }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'viewer is also admin' do
      let (:viewing_user) { admin }

      context 'disabled_api', organization_api_enabled: false do
        include_examples 'responds with disabled api'
      end

      context 'enabled_api', organization_api_enabled: true do
        include_examples 'responds with disabled api'
      end
    end
  end

  describe 'PATCH rotate_api_token' do
    # Server Variables:
    let (:admin) { FactoryBot.create(:user) }
    let (:api_enabled) { false }
    let (:api_token) { nil }
    let (:organization) { FactoryBot.create(:organization, api_enabled: api_enabled, api_token: api_token, admin: admin) }

    # Client Variables:
    let (:viewing_user) { nil }

    # Shared Contextes:
    shared_context 'api enabled', organization_api_enabled: true do
      let (:api_enabled) { true }
      let (:api_token) { 'a' * 32 }
    end
    shared_context 'api disabled', organization_api_enabled: false do
      let (:api_enabled) { false }
      let (:api_token) { nil }
    end

    # Shared Examples:
    shared_examples 'responds with rotated api token' do
      it { is_expected.to respond_with :ok }

      it 'renders an organization with api enabled' do
        rendered_body = JSON.parse(response.body)
        rendered_token = rendered_body['api_token']
        rendered_api_enabled = rendered_body['api_enabled']

        if api_token.present?
          expect(rendered_token).to be_truthy
          expect(rendered_token.length).to be >= 32
          expect(rendered_token).not_to eq api_token
        end
      end
    end

    before do
      organization
      viewing_user

      setup_knock(viewing_user) if viewing_user.present?
      patch :rotate_api_token, params: { id: organization.id }
    end

    context 'logged out viewer' do
      let (:viewing_user) { nil }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'logged in viewer who is not member, not admin' do
      let (:viewing_user) { FactoryBot.create(:user) }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'logged in viewer who is member, not admin' do
      let (:viewing_user) {
        user = FactoryBot.create(:user)
        FactoryBot.create(:user_organization_membership, user: user, organization: organization)
        user
      }
      it { is_expected.to respond_with :unauthorized }
    end

    context 'viewer is also admin' do
      let (:viewing_user) { admin }
      context 'disabled_api', organization_api_enabled: false do
        it { is_expected.to respond_with :unprocessable_entity }
      end

      context 'enabled_api', organization_api_enabled: true do
        include_examples 'responds with rotated api token'
      end
    end
  end
end
