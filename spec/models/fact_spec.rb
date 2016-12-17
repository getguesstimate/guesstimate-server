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
    let (:exported_from) { nil }
    let (:metric_id) { nil }
    subject (:fact) {
      FactoryGirl.build(
        :fact,
        organization: organization,
        name: name,
        expression: expression,
        variable_name: variable_name,
        simulation: simulation,
        exported_from: exported_from.present? ? exported_from : nil,
        metric_id: metric_id,
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

    context 'with exported space' do
      let (:exported_from) { FactoryGirl.create(:space) }

      context 'without a metric id' do
        let (:metric_id) { nil }
        it { is_expected.to_not be_valid }
      end

      context 'with a metric id' do
        let (:metric_id) { '3' }

        before { exported_from }

        it { is_expected.to be_valid }
        it 'increments the exported_from exported_facts_count upon creation' do
          expect{fact.save}.to change{exported_from.exported_facts_count}.from(0).to(1)
        end
      end

      context 'non unique metric id' do
        let (:other_fact_exported_from) { nil }
        let (:metric_id) {
          id = '3'
          FactoryGirl.create :fact, exported_from: other_fact_exported_from, metric_id: id
          id
        }

        context 'across different spaces' do
          let (:other_fact_exported_from) { FactoryGirl.create :space }
          it { is_expected.to be_valid }
        end

        context 'within one space' do
          let (:other_fact_exported_from) { exported_from }
          it { is_expected.to_not be_valid }
        end
      end
    end
  end

  describe '#destroy' do
    let (:exported_from) { FactoryGirl.create(:space) }
    let (:metric_id) { '3' }
    subject (:fact) { FactoryGirl.create(:fact, exported_from: exported_from, metric_id: metric_id) }

    before do
      exported_from
      fact
    end

    it 'decrements exported_facts_count' do
      expect{fact.destroy}.to change{exported_from.exported_facts_count}.from(1).to(0)
    end
  end

  describe 'take_checkpoint' do
    let (:by_api) { false }
    let (:author) { FactoryGirl.create(:user) }
    let (:first_checkpoint) { FactoryGirl.create(:fact_checkpoint, fact: fact, created_at: 0) }
    let (:checkpoint) { fact.take_checkpoint(author, by_api) }
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
      it 'matches the fact' do
        expect(checkpoint).to be_valid
        expect(checkpoint.fact_id).to eq fact.id
        expect(checkpoint.author_id).to eq author.nil? ? nil : author.id
        expect(checkpoint.by_api).to eq by_api
        expect(checkpoint.simulation).to eq fact.simulation
        expect(checkpoint.name).to eq fact.name
        expect(checkpoint.variable_name).to eq fact.variable_name
        expect(checkpoint.expression).to eq fact.expression
      end

      it 'has the new checkpoint as a checkpoint' do
        expect(fact.checkpoints.where(id: checkpoint.id).count).to be 1
      end
    end

    context 'with fewer checkpoints than the history cutoff' do
      include_examples 'the new checkpoint matches the fact and is not deleted'
      it 'still has the first_checkpoint' do
        expect(fact.checkpoints.count).to be 2
        expect(fact.checkpoints.where(id: first_checkpoint.id).count).to be 1
      end

      context 'with no author, by api' do
        let (:author) { nil }
        let (:by_api) { true }
        include_examples 'the new checkpoint matches the fact and is not deleted'
      end
    end

    context 'with more checkpoints than the history cutoff' do
      include_examples 'the new checkpoint matches the fact and is not deleted'
      let (:num_other_facts) { checkpoint_limit }

      it 'deletes the oldest checkpoint if it has more checkpoints than the history cutoff' do
        expect(fact.checkpoints.count).to be checkpoint_limit
        expect(fact.checkpoints.where(id: first_checkpoint.id).count).to be 0
      end
    end
  end

  describe '#imported_to_intermediate_spaces' do
    let (:organization) { FactoryGirl.create(:organization) }
    let (:imported_fact) { FactoryGirl.create(:fact, organization: organization) }
    let (:exported_from) {
      imported_fact
      FactoryGirl.create(
        :space,
        organization: organization,
        graph: {'guesstimates' => [ {'expression'=>"=${fact:#{imported_fact.id}}"} ]},
        imported_fact_ids: [imported_fact.id],
        exported_facts_count: 1,
      )
    }
    subject (:space_ids) {
      exported_from
      imported_fact.imported_to_intermediate_space_ids
    }

    it 'yields the correct imported_to_intermediate_space_ids' do
      expect(space_ids).to contain_exactly(exported_from.id)
    end
  end
end
