require 'rails_helper'
require 'spec_helper'

RSpec.describe Space, type: :model do
  describe '#create' do
    let (:user) { FactoryGirl.create(:user) }
    let (:viewcount) { nil } # default context unviewed.
    let (:is_private) { false } # default context public.
    let (:shareable_link_enabled) { false }
    let (:shareable_link_token) { nil }

    subject (:space) {
      FactoryGirl.build(
        :space,
        user: user,
        is_private: is_private,
        viewcount: viewcount,
        shareable_link_enabled: shareable_link_enabled,
        shareable_link_token: shareable_link_token,
      )
    }

    # A public, unviewed space should be valid.
    it { is_expected.to be_valid }

    context 'with shareable link enabled' do
      let (:shareable_link_enabled) { true }

      context 'with no token on a private space' do
        let (:is_private) { true }
        it { is_expected.not_to be_valid }
      end

      context 'with a too short token on a private space' do
        let (:is_private) { true }
        let (:shareable_link_token) { 'a' * 31 }
        let (:user) { FactoryGirl.create(:user, :lite_plan) }
        it { is_expected.not_to be_valid }
      end

      context 'with a valid token on a public space' do
        let (:is_private) { false }
        let (:shareable_link_token) { 'a' * 32 }
        it { is_expected.not_to be_valid }
      end

      context 'with a valid token on a private space' do
        let (:is_private) { true }
        let (:shareable_link_token) { 'a' * 32 }
        let (:user) { FactoryGirl.create(:user, :lite_plan) }
        it { is_expected.to be_valid }
      end
    end

    context 'negative viewcount' do
      let(:viewcount) {-1}
      it { is_expected.not_to be_valid }
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

    it 'is not searchable with no graph' do
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
      it 'is searchable with a valid graph' do
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
      it 'is searchable with a valid graph' do
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
      it 'copies properly' do
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
        organization = FactoryGirl.create(:organization, plan: :organization_basic_30)
        FactoryGirl.create(:user_organization_membership, user: copying_user, organization: organization)
        organization
      }
      let (:should_copy_be_private) { true }

      include_examples('copies properly')
    end
  end

  describe '#save' do
    subject(:space) { FactoryGirl.create(:space) }
    let(:new_graph) {
      {
        'guesstimates' => [
          {'expression'=>'=${fact:1} + ${fact:2} + ${fact:1}'},
          {'expression'=>'=${fact:2} + ${fact:3} + ${fact:40}'},
          {'expression'=>'=${fact:1} + ${fact:2} + fact:77'}
        ]
      }
    }

    it 'updates imported_fact_ids' do
      expect{space.update! graph: new_graph}.to change{space.imported_fact_ids}.from([])
      expect(space.imported_fact_ids).to contain_exactly(1, 2, 3, 40)
    end
  end

  describe '#get_imported_fact_ids' do
    let(:guesstimates) { [] }
    let(:space) { FactoryGirl.build(:space, graph: guesstimates.empty? ? nil : {'guesstimates' => guesstimates}) }
    subject(:fact_ids) { space.get_imported_fact_ids }

    context 'without facts' do
      it 'returns an empty array with no graph' do
        expect(fact_ids).to be_empty
      end
    end

    context 'with facts' do
      let(:guesstimates) {[
        {'expression'=>'=${fact:1} + ${fact:2} + ${fact:1}'},
        {'expression'=>'=${fact:2} + ${fact:3} + ${fact:40}'},
        {'expression'=>'=${fact:1} + ${fact:2} + fact:77'}
      ]}
      it 'contains the referenced facts' do
        expect(fact_ids).to contain_exactly('1', '2', '3', '40')
      end
    end
  end

  describe '#enable_shareable_link!' do
    context 'with shareable_link disabled' do
      subject(:space) { FactoryGirl.create :space }
      it 'enables shareable link' do
        expect { space.enable_shareable_link! }
          .to  change { space.shareable_link_enabled }.from(false).to(true)
          .and change { space.shareable_link_token   }.from(nil)
      end
    end

    context 'with shareable link_enabled' do
      subject(:space) { FactoryGirl.create :space, :shareable_link_enabled }
      it 'does not modify the shareable link token and does not disable shareable link' do
        expect { space.enable_shareable_link! }.to_not change { space.shareable_link_token }
        expect { space.enable_shareable_link! }.to_not change { space.shareable_link_enabled }.from(true)
      end
    end
  end

  describe '#disable_shareable_link!' do
    subject(:space) { FactoryGirl.create :space, :shareable_link_enabled }

    it 'disables shareable link' do
      expect { space.disable_shareable_link! }
        .to  change { space.shareable_link_enabled }.from(true).to(false)
        .and change { space.shareable_link_token   }.to(nil)
    end
  end

  describe '#rotate_shareable_link!' do
    context 'with shareable link_enabled' do
      subject(:space) { FactoryGirl.create :space, :shareable_link_enabled }
      it 'rotates the shareable link token and does not disable shareable link' do
        expect { space.rotate_shareable_link! }.to change { space.shareable_link_token }
        expect { space.rotate_shareable_link! }.to_not change { space.shareable_link_enabled }.from(true)

        expect(space.shareable_link_token).to_not be_nil
      end
    end
    context 'with shareable link disabled' do
      subject(:space) { FactoryGirl.create :space }
      it 'does not change the shareable link token' do
        expect { space.rotate_shareable_link! }.to_not change { space.shareable_link_token }.from(nil)
        expect { space.rotate_shareable_link! }.to_not change { space.shareable_link_enabled }.from(false)
      end
    end
  end

  describe '#shareable_link_url' do
    context 'with shareable link enabled' do
      subject(:space) {
        FactoryGirl.build(
          :space,
          shareable_link_enabled: true,
          shareable_link_token: 'token------------------------------', # Padded to be > 32 characters, for validation limit.
          id: 1,
        )
      }
      it 'gets the correct link' do
        expect(space.shareable_link_url).to eq 'http://localhost:3000/models/1?token=token------------------------------'
      end
    end
    context 'with shareable link disabled' do
      subject(:space) { FactoryGirl.build :space, shareable_link_enabled: false, shareable_link_token: 'shouldNotShow', id: 1 }
      it 'gets the correct link' do
        expect(space.shareable_link_url).to eq ''
      end
    end
  end
end
