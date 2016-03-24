require 'rails_helper'
require 'spec_helper'

RSpec.describe Space, type: :model do
  describe '#create' do
    let (:creator) { FactoryGirl.create(:user) }
    let (:viewcount) { nil } # default context unviewed.
    let (:is_private) { false } # default context public.

    subject (:space) { FactoryGirl.build(:space, creator: creator, is_private: is_private, viewcount: viewcount) }

    # A public, unviewed space should be valid.
    it { is_expected.to be_valid } 

    context 'negative viewcount' do
      let(:viewcount) {-1}
      it { is_expected.not_to be_valid}
    end

    context 'private space' do
      let(:is_private) { true }

      context 'with creator on free plan' do
        it { is_expected.not_to be_valid }
      end

      context 'with creator on lite plan' do
        let (:creator) { FactoryGirl.create(:user, :lite_plan) }
        it { is_expected.to be_valid }
      end
    end

    context 'creator should be owner' do
      it 'should make the creator an owner upon save' do
        space.save
        expect(space.owners.count).to eq 1
        expect(space.owners.first).to eq creator
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

    context 'searchable graph lognormal' do
      let(:graph) {
        {'metrics'=>
          [{'name'=>'Point Test'},
           {'name'=>'Uniform Test'},
           {'name'=>'LogNormal Test'},
           {'name'=>'Function Test'}],
         'guesstimates'=>
          [{'guesstimateType'=>'POINT'},
           {'guesstimateType'=>'UNIFORM'},
           {'guesstimateType'=>'LOGNORMAL'},
           {'guesstimateType'=>'FUNCTION'}]}
      }
      it 'should be searchable with a valid graph' do
        expect(space.is_searchable?).to be true
      end
    end
  end

  describe '#copy' do
    # We hardcode the id to make the graph valid.
    let(:creator) { FactoryGirl.create(:user, username: 'creator') }
    let(:copying_user) { FactoryGirl.create(:user, username: 'copying_user') }
    let(:graph) {
      {'metrics'=>
        [{'id'=>'3', 'readableId'=>'AR', 'name'=>'Point', 'location'=>{'row'=>1, 'column'=>0}},
         {'id'=>'4', 'readableId'=>'QK', 'name'=>'Uniform', 'location'=>{'row'=>1, 'column'=>1}},
         {'id'=>'5', 'readableId'=>'EU', 'name'=>'Lognormal', 'location'=>{'row'=>2, 'column'=>0}},
         {'id'=>'6', 'readableId'=>'DF', 'name'=>'Normal', 'location'=>{'row'=>3, 'column'=>1}}],
       'guesstimates'=>
        [{'metric'=>'3', 'input'=>'3', 'guesstimateType'=>'POINT', 'description'=>''},
         {'metric'=>'4', 'input'=>'[1,2]', 'guesstimateType'=>'UNIFORM', 'description'=>''},
         {'metric'=>'5', 'input'=>'=lognormal(AR,QK)', 'guesstimateType'=>'FUNCTION', 'description'=>''},
         {'metric'=>'6', 'input'=>'[1,3]', 'guesstimateType'=>'NORMAL', 'description'=>''}]}
    }
    let(:space) { FactoryGirl.create(:space, creator: creator, graph: graph) }

    subject(:copy) {space.copy(copying_user)}

    it 'should copy properly' do
      expect(copy.copied_from).to eq space

      expect(space.copies.count).to eq 1
      expect(space.copies.first).to eq copy

      expect(copy.name).to eq space.name
      expect(copy.creator).to be copying_user
      expect(copy.owners.count).to eq 1
      expect(copy.owners.first).to eq copying_user

      copy.save!

      # After saving, we should have new id and graph.
      expect(copy.id).not_to eq space.id
      expect(copy.graph).to eq graph
    end

    context 'with nil graph' do
      let(:graph) { nil }

      it 'should copy properly' do
        expect(copy.name).to eq space.name
        expect(copy.creator).to be copying_user
        expect(copy.id).not_to eq space.id
        expect(copy.graph).to be nil
      end
    end
  end
end
