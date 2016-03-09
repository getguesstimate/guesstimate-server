require 'rails_helper'
require 'spec_helper'

RSpec.describe Space, type: :model do

    describe '#create' do
      let (:user) { FactoryGirl.create(:user) }
      let (:viewcount) { nil } # default context unviewed.
      let (:is_private) { false } # default context public.

      subject (:space) { FactoryGirl.build(:space, user: user, is_private: is_private, viewcount: viewcount) }

      # A public, unviewed space should be valid.
      it { is_expected.to be_valid } 

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

      context 'negative viewcount' do
        let(:viewcount) {-1}
        it { is_expected.not_to be_valid}
      end
    end
end
