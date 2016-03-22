require 'rails_helper'

RSpec.describe OrganizationSpacePermission, type: :model do
  describe '#create' do
    let (:space) { FactoryGirl.create :space }
    let (:organization) { FactoryGirl.create :organization }
    let (:access_type) { :exposed }
    subject (:permission) { FactoryGirl.build :organization_space_permission, space: space, organization: organization, access_type: access_type }

    it { is_expected.to be_valid }

    context 'no space' do
      let (:space) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no organization' do
      let (:organization) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no access_type' do
      let (:access_type) { nil }
      it { is_expected.to_not be_valid }
    end
  end
end
