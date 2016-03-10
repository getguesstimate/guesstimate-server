require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#private_model_limit' do
    subject (:private_model_limit) { user.private_model_limit}

    context 'a free user' do
      let (:user) { FactoryGirl.create(:user) }
      it { is_expected.to eq(0) }
    end

    context 'a user on a lite plan' do
      let (:user) { FactoryGirl.create(:user, :lite_plan) }
      it { is_expected.to eq(20) }
    end

    context 'a user on a premium plan' do
      let (:user) { FactoryGirl.create(:user, :premium_plan) }
      it { is_expected.to eq(100) }
    end
  end
end
