require 'rails_helper'
require 'spec_helper'

def setup_knock(user)
  request.headers['authorization'] = 'Bearer JWTTOKEN'
  knock = double("Knock")
  allow(knock).to receive(:current_user).and_return(user)
  allow(knock).to receive(:validate!).and_return(true)
  allow(Knock::AuthToken).to receive(:new).and_return(knock)
end

RSpec.describe UserOrganizationMembershipsController, type: :controller do
  describe 'DELETE destroy' do
    let (:membership) { FactoryGirl.create(:user_organization_membership) }

    context 'when logged out' do
      before { delete :destroy, id: membership.id }

      it { is_expected.to respond_with :unauthorized }
      it 'should not have deleted the membership' do
        expect(UserOrganizationMembership.find(membership.id)).to eq membership
      end
    end

    context 'when logged in' do
      let (:requesting_user) { nil } # overwritten in each context below
      before do
        setup_knock(requesting_user)
        delete :destroy, id: membership.id
      end

      context 'when admin' do
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

      context 'when member but not admin' do
        let (:requesting_user) {
          user = FactoryGirl.create(:user)
          organization = membership.organization
          FactoryGirl.create(:user_organization_membership, user: user, organization: organization)
          user
        }

        it { is_expected.to respond_with :unauthorized }
        it 'should not have deleted the membership' do
          expect(UserOrganizationMembership.find(membership.id)).to eq membership
        end
      end

      context 'when not member' do
        let (:requesting_user) { FactoryGirl.create(:user) }

        it { is_expected.to respond_with :unauthorized }
        it 'should not have deleted the membership' do
          expect(UserOrganizationMembership.find(membership.id)).to eq membership
        end
      end
    end
  end
end
