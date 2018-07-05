require 'rails_helper'

RSpec.describe Calculator, type: :model do
  describe '#create' do
    let (:space) { FactoryBot.build(:space) }
    let (:title) { 'title' }
    let (:input_ids) { ['1'] }
    let (:output_ids) { ['1'] }
    subject (:calculator) { FactoryBot.build(:calculator, space: space, title: title, input_ids: input_ids, output_ids: output_ids) }

    it { is_expected.to be_valid }

    context 'no space' do
      let (:space) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no title' do
      let (:title) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no input_ids' do
      let (:input_ids) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no output_ids' do
      let (:output_ids) { nil }
      it { is_expected.to_not be_valid }
    end
  end
end
