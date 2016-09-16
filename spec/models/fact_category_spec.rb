require 'rails_helper'

RSpec.describe FactCategory, type: :model do
  describe '#create' do
    let (:name) { 'category name' }
    let (:organization) { FactoryGirl.create :organization }
    let (:other_organization_fact_category) { FactoryGirl.create :fact_category, organization: organization }
    let (:other_non_organization_fact_category) { FactoryGirl.create :fact_category }
    subject (:fact_category) { FactoryGirl.build :fact_category, name: name, organization: organization }

    it { is_expected.to be_valid }

    context 'no name' do
      let (:name) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no organization' do
      let (:organization) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'duplicate name' do
      context 'duplicate within organization' do
        let (:name) { other_organization_fact_category.name }
        it { is_expected.to_not be_valid }
      end

      context 'duplicate across organizations' do
        let (:name) { other_non_organization_fact_category.name }
        it { is_expected.to be_valid }
      end
    end
  end
end
