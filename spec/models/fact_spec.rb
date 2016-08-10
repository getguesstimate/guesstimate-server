require 'rails_helper'

RSpec.describe Fact, type: :model do
  describe '#create' do
    let (:organization) { FactoryGirl.build(:organization) }
    let (:name) { 'name' }
    let (:expression) { '199' }
    let (:variable_name) { 'var_1' }
    let (:stats) { {"mean" => 1, "stdev" => 0, "length" => 1} }
    let (:values) { [1] }
    let (:errors) { [] }
    let (:simulation) { {"sample" => {"values" => values, "errors" => errors}, "stats" => stats} }
    subject (:fact) {
      FactoryGirl.build(
        :fact,
        organization: organization,
        name: name,
        expression: expression,
        variable_name: variable_name,
        simulation: simulation,
      )
    }

    it { is_expected.to be_valid }

    context 'no organization' do
      let (:organization) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no name' do
      let (:name) { nil }
      it { is_expected.to be_valid }
    end

    context 'no expression' do
      let (:expression) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no variable_name' do
      let (:variable_name) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'improper variable_name' do
      let (:variable_name) { 'this is not allowed.' }
      it { is_expected.to_not be_valid }
    end

    context 'non-unique variable_name' do
      let (:variable_name) {
        name = 'foo'
        FactoryGirl.create(:fact, organization: organization, variable_name: name)
        name
      }
      it { is_expected.to_not be_valid }
    end

    context 'no simulation' do
      let (:simulation) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'simulation with no values' do
      let (:values) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'simulation with errors' do
      let (:errors) { [{"type" => "Math Error", "msg" => "Invalid Sample"}] }
      it { is_expected.to_not be_valid }
    end

    context 'simulation with no stats' do
      let (:stats) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'simulation with multiple samples and no percentiles' do
      let (:values) { [1,2,3] }
      let (:stats) { {"mean" => 0.5, "length" => 3, "stdev" => 1} }
      it { is_expected.to_not be_valid }
    end
  end

  describe 'take_checkpoint' do
    let (:author) { FactoryGirl.create(:user) }
    let (:first_checkpoint) { FactoryGirl.create(:fact_checkpoint, fact: fact, created_at: 0) }
    let (:checkpoint) { fact.take_checkpoint(author) }
    let (:num_other_facts) { 0 }
    let (:checkpoint_limit) { 5 }
    subject (:fact) { FactoryGirl.create(:fact) }

    before do
      first_checkpoint

      stub_const "Fact::CHECKPOINT_LIMIT", checkpoint_limit # We want to reach the history cutoff with little work.
      num_other_facts.times { FactoryGirl.create(:fact_checkpoint, fact: fact) }

      checkpoint
    end

    shared_examples 'the new checkpoint matches the fact and is not deleted' do
      it 'should match the fact' do
        expect(checkpoint).to be_valid
        expect(checkpoint.fact_id).to eq fact.id
        expect(checkpoint.author_id).to eq author.id
        expect(checkpoint.simulation).to eq fact.simulation
        expect(checkpoint.name).to eq fact.name
        expect(checkpoint.variable_name).to eq fact.variable_name
        expect(checkpoint.expression).to eq fact.expression
      end

      it 'should have the new checkpoint as a checkpoint' do
        expect(fact.checkpoints.where(id: checkpoint.id).count).to be 1
      end
    end

    context 'with fewer checkpoints than the history cutoff' do
      include_examples 'the new checkpoint matches the fact and is not deleted'
      it 'should still have the first_checkpoint' do
        expect(fact.checkpoints.count).to be 2
        expect(fact.checkpoints.where(id: first_checkpoint.id).count).to be 1
      end
    end

    context 'with more checkpoints than the history cutoff' do
      include_examples 'the new checkpoint matches the fact and is not deleted'
      let (:num_other_facts) { checkpoint_limit }

      it 'should delete the oldest checkpoint if it has more checkpoints than the history cutoff' do
        expect(fact.checkpoints.count).to be checkpoint_limit
        expect(fact.checkpoints.where(id: first_checkpoint.id).count).to be 0
      end
    end
  end
end
