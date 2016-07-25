require 'rails_helper'

RSpec.describe Fact, type: :model do
  describe '#create' do
    let (:organization) { FactoryGirl.build(:organization) }
    let (:name) { 'name' }
    let (:expression) { '199' }
    let (:variable_name) { 'var_1' }
    subject (:fact) { FactoryGirl.build(:fact, organization: organization, name: name, expression: expression, variable_name: variable_name) }

    it { is_expected.to be_valid }

    context 'no organization' do
      let (:organization) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no name' do
      let (:name) { nil }
      it { is_expected.to_not be_valid }
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
  end
end
