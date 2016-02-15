require 'rails_helper'
require 'spec_helper'

RSpec.describe Space, type: :model do

    describe '#create' do
      let (:user) { FactoryGirl.create(:user) }
      subject (:space) { FactoryGirl.build(:space, user: user, is_private: is_private) }

      context 'public' do
        let (:is_private) { false }
        it { is_expected.to be_valid }
      end

      context 'private' do
        let (:is_private) { true }

        context 'with user on free plan' do
          it { is_expected.not_to be_valid }
        end

        context 'with user on small plan' do
          let (:user) { FactoryGirl.create(:user, :small_plan) }
          it { is_expected.to be_valid }
        end
      end

    end
end
