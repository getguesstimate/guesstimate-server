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

  describe '#copy' do
    subject(:space) { FactoryGirl.create(:space, name: name, user: base_user, graph: graph) }

    let(:name) { 'Test' }
    let(:base_user) { FactoryGirl.create(:user, username: "base_user") }
    let(:copying_user) { FactoryGirl.create(:user, username: "copying_user") }
    let(:graph) {
      {"metrics"=>
        [{"id"=>"3", "space"=>17, "readableId"=>"AR", "name"=>"Point", "location"=>{"row"=>1, "column"=>0}},
         {"id"=>"4", "space"=>17, "readableId"=>"QK", "name"=>"Uniform", "location"=>{"row"=>1, "column"=>1}},
         {"id"=>"5", "space"=>17, "readableId"=>"EU", "name"=>"Lognormal", "location"=>{"row"=>2, "column"=>0}},
         {"id"=>"6", "space"=>17, "readableId"=>"DF", "name"=>"Normal", "location"=>{"row"=>3, "column"=>1}}],
       "guesstimates"=>
        [{"metric"=>"3", "input"=>"3", "guesstimateType"=>"POINT", "description"=>""},
         {"metric"=>"4", "input"=>"[1,2]", "guesstimateType"=>"UNIFORM", "description"=>""},
         {"metric"=>"5", "input"=>"=lognormal(AR,QK)", "guesstimateType"=>"FUNCTION", "description"=>""},
         {"metric"=>"6", "input"=>"[1,3]", "guesstimateType"=>"NORMAL", "description"=>""}]}
    }

    it 'should copy properly' do
      s = space.copy(copying_user)

      expect(s.copied_from).to eq space

      expect(space.copies.count).to eq 1
      expect(space.copies.first).to eq s

      expect(s.name).to eq name
      expect(s.user).to be copying_user

      s.save!

      copied_graph = graph
      copied_graph["metrics"].each { |metric| metric["space"] = s.id }

      # After saving, we should have new id and graph.
      expect(s.id).not_to eq space.id
      expect(s.graph).to eq copied_graph
    end

    context 'with nil graph' do
      let(:graph) { nil }

      it 'should copy properly' do
        s = space.copy(copying_user)
        expect(s.name).to eq name
        expect(s.user).to be copying_user
        expect(s.id).not_to eq space.id
        expect(s.graph).to be nil
      end
    end
  end
end
