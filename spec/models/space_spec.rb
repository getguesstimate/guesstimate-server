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
    let(:base_user) { FactoryGirl.create(:user) }
    let(:base_organization) { nil }
    let(:copying_user) { FactoryGirl.create(:user) }
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
    let(:space) { FactoryGirl.create(:space, user: base_user, organization: base_organization, graph: graph) }
    let(:should_copy_be_private) { false }

    subject(:copy) {space.copy(copying_user)}

    shared_examples 'copies properly' do
      it 'should copy properly' do
        expect(copy.copied_from).to eq space
        expect(space.copies.count).to eq 1
        expect(space.copies.first).to eq copy
        expect(copy.name).to eq space.name
        expect(copy.user).to be copying_user
        expect(copy.id).not_to eq space.id
        expect(copy.graph).to eq graph
        expect(copy.is_private).to eq should_copy_be_private
      end
    end

    include_examples('copies properly')

    context 'with nil graph' do
      let(:graph) { nil }
      include_examples('copies properly')
    end

    context 'with user who prefers private' do
      let (:copying_user) { FactoryGirl.create(:user, :lite_plan) }
      let (:should_copy_be_private) { true }

      include_examples('copies properly')
    end

    context 'with non-membered base organization' do
      let (:base_organization) { FactoryGirl.create(:organization) }
      include_examples('copies properly')
    end

    context 'with membered free base organization' do
      let (:base_organization) {
        organization = FactoryGirl.create(:organization, plan: :organization_free)
        FactoryGirl.create(:user_organization_membership, user: copying_user, organization: organization)
        organization
      }
      let (:should_copy_be_private) { false }

      include_examples('copies properly')
    end

    context 'with membered base organization' do
      let (:base_organization) {
        organization = FactoryGirl.create(:organization, plan: :organization_basic)
        FactoryGirl.create(:user_organization_membership, user: copying_user, organization: organization)
        organization
      }
      let (:should_copy_be_private) { true }

      include_examples('copies properly')
    end
  end

  describe '#get_fact_ids_used' do
    let(:guesstimates) { [] }
    let(:space) { FactoryGirl.build(:space, graph: guesstimates.empty? ? nil : {'guesstimates' => guesstimates}) }
    subject(:fact_ids) { space.get_fact_ids_used }

    it 'should return an empty array with no graph' do
      expect(fact_ids).to be_empty
    end

    context 'graph with facts' do
      let(:guesstimates) {[
        {'expression'=>'=${fact:1} + ${fact:2} + ${fact:1}'},
        {'expression'=>'=${fact:2} + ${fact:3} + ${fact:40}'},
        {'expression'=>'=${fact:1} + ${fact:2} + fact:77'}
      ]}
      it 'should contain the referenced fact' do
        expect(fact_ids).to contain_exactly('1', '2', '3', '40')
      end
    end
  end

end
