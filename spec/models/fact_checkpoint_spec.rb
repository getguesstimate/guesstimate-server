require 'rails_helper'

RSpec.describe FactCheckpoint, type: :model do
  describe '#create' do
    let (:fact) { FactoryBot.create(:fact) }
    let (:by_api) { false }
    let (:author) { FactoryBot.create(:user) }
    let (:simulation) { JSON.generate sample: {values: [1], errors: []}, stats: {mean: 1, stdev: 0, length: 1} }

    subject (:checkpoint) { FactoryBot.build(:fact_checkpoint, by_api: by_api, fact: fact, simulation: simulation, author: author) }

    it { is_expected.to be_valid }

    context 'No fact' do
      let (:fact) {nil}
      it { is_expected.not_to be_valid }
    end

    context 'No simulation' do
      let (:simulation) {nil}
      it { is_expected.not_to be_valid }
    end

    context 'No author' do
      let (:author) {nil}

      context 'Not by api' do
        it { is_expected.not_to be_valid }
      end

      context 'By api' do
        let (:by_api) { true }
        it { is_expected.to be_valid }
      end
    end
  end
end
