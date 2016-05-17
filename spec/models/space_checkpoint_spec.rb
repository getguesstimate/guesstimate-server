require 'rails_helper'

RSpec.describe SpaceCheckpoint, type: :model do
  describe '#create' do
    let (:space) { FactoryGirl.create(:space) }
    let (:graph) { JSON.generate metrics: [], guesstimates: [] }

    subject (:checkpoint) { FactoryGirl.build(:space_checkpoint, space: space, graph: graph) }

    it { is_expected.to be_valid }

    context 'No space' do
      let (:space) {nil}
      it { is_expected.not_to be_valid }
    end

    context 'No graph' do
      let (:graph) {nil}
      it { is_expected.not_to be_valid }
    end
  end
end
