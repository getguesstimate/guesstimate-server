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

    context 'negative viewcount' do
      let(:viewcount) {-1}
      it { is_expected.not_to be_valid}
    end

    context 'private space' do
      let(:is_private) { true }

      context 'with user on free plan' do
        it { is_expected.not_to be_valid }
      end

      context 'with user on lite plan' do
        let (:user) { FactoryGirl.create(:user, :lite_plan) }
        it { is_expected.to be_valid }
      end
    end
  end

  describe '#searchable' do
    subject(:space) { FactoryGirl.build(:space, name: name, graph: graph) }
    let(:graph) {nil}
    let(:name) {'real model'}

    it 'should not be searchable with no graph' do
      expect(space.is_searchable?).to be false
    end

    context 'searchable graph' do
      let(:graph) {
        {'metrics'=>
          [{'name'=>'Point Test'},
           {'name'=>'Uniform Test'},
           {'name'=>'Normal Test'},
           {'name'=>'Function Test'}],
         'guesstimates'=>
          [{'guesstimateType'=>'POINT'},
           {'guesstimateType'=>'UNIFORM'},
           {'guesstimateType'=>'NORMAL'},
           {'guesstimateType'=>'FUNCTION'}]}
      }
      it 'should be searchable with a valid graph' do
        expect(space.is_searchable?).to be true
      end
    end
  end
end
