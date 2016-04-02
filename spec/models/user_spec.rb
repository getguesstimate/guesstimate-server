require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#create' do
    let (:username) { "username" }
    let (:name) { "name" }
    let (:email) { "email@email.com" }
    let (:auth0_id) { "auth0_id" }
    subject (:user) { FactoryGirl.build(:user, username: username, name: name, email: email, auth0_id: auth0_id) }

    it { is_expected.to be_valid }

    context 'no username' do
      let (:username) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no name' do
      let (:name) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'no email' do
      let (:email) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'bad email' do
      let (:email) { "email.com" }
      it { is_expected.to_not be_valid }
    end

    context 'no auth0_id' do
      let (:auth0_id) { nil }
      it { is_expected.to_not be_valid }
    end
  end

  describe '#private_model_limit' do
    subject (:private_model_limit) { user.private_model_limit}

    context 'a free user' do
      let (:user) { FactoryGirl.create(:user) }
      it { is_expected.to eq(0) }
    end

    context 'a user on a lite plan' do
      let (:user) { FactoryGirl.create(:user, :lite_plan) }
      it { is_expected.to eq(20) }
    end

    context 'a user on a premium plan' do
      let (:user) { FactoryGirl.create(:user, :premium_plan) }
      it { is_expected.to eq(100) }
    end
  end

  describe '#domain_name' do
    let (:email) { 'foo@barcom.com' }
    let (:user) {FactoryGirl.build(:user, email: email) }
    subject (:domain_name) { user.domain_name }

    it { is_expected.to eq('barcom') }

    context '.net address' do
      let (:email) { 'foo@barnet.net' }
      it { is_expected.to eq('barnet') }
    end
  end
end
