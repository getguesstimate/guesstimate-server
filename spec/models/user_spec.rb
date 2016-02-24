require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#private_model_limit' do
    subject (:private_model_limit) { user.private_model_limit}

    context 'a free user' do
      let (:user) { FactoryGirl.create(:user) }
      it { is_expected.to eq(0) }
    end

    context 'a user on a small plan' do
      let (:user) { FactoryGirl.create(:user, :small_plan) }
      it { is_expected.to eq(15) }
    end

    context 'a user on a large plan' do
      let (:user) { FactoryGirl.create(:user, :large_plan) }
      it { is_expected.to eq(60) }
    end
  end
end
