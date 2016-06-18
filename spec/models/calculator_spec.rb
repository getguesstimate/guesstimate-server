require 'rails_helper'

RSpec.describe Calculator, type: :model do
  describe '#Create' do
    let (:space) { FactoryGirl.build(:space) }
    subject (:calculator) { FactoryGirl.build(:calculator, space: space) }

    it { is_expected.to be_valid }

    context 'no space' do
      let (:space) { nil }
      it { is_expected.to_not be_valid }
    end
  end
end
