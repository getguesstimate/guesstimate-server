require 'rails_helper'

RSpec.describe Fact, type: :model do
  describe '#create' do
    let (:organization) { FactoryGirl.build(:organization) }
    let (:name) { 'name' }
    let (:expression) { '199' }
    let (:variable_name) { 'var_1' }
    let (:simulation) { {"sample" => { "values" => [1], "errors" => [] }, "stats" => { "mean" => 1, "stdev" => 0, "length" => 1 }} }
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
      let (:simulation) { {"sample" => {}} }
      it { is_expected.to_not be_valid }
    end

    context 'simulation with errors' do
      let (:simulation) { {"sample" => {"values" => [1], "errors" => [{"type" => "Math Error", "msg" => "Invalid Sample"}]}} }
      it { is_expected.to_not be_valid }
    end
  end
end
