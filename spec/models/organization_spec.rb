require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe '#create' do
    let (:admin) { FactoryGirl.create(:user) }
    subject (:organization) { FactoryGirl.build(:organization, admin: admin) }

    it { is_expected.to be_valid }

    context 'no admin' do
      let (:admin) { nil }
      it { is_expected.to_not be_valid }
    end
  end

  describe 'after create' do
    let (:admin) { FactoryGirl.create(:user) }
    let (:organization) { FactoryGirl.create(:organization, admin: admin) }
    subject (:members) {organization.members}

    it { is_expected.to match_array [admin] }
  end
end
