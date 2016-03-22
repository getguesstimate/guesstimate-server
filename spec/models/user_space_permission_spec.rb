require 'rails_helper'

RSpec.describe UserSpacePermission, type: :model do
  describe '#create' do
    let (:user) { FactoryGirl.create(:user) }
    let (:space) { FactoryGirl.create(:space) }
    let (:access_type) { :own }

    subject (:permission) { FactoryGirl.build(:user_space_permission, user: user, space: space, access_type: access_type) }

    it { is_expected.to be_valid }

    context 'no user' do
      let (:user) { nil }
      it { is_expected.not_to be_valid }
    end

    context 'no space' do
      let (:space) { nil }
      it { is_expected.not_to be_valid }
    end

    context 'no access_type' do
      let (:access_type) { nil }
      it { is_expected.not_to be_valid }
    end
  end
end
