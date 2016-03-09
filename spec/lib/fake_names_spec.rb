require 'rails_helper'
require 'spec_helper'

describe "fake names" do
  let(:dummy_class) {
    Class.new {
      include FakeNames
      def initialize(name)
        @name = name
      end
      attr_reader :name
    }
  }
  subject(:c) { dummy_class.new(name) }

  context 'with valid name' do
    let(:name) {"real model"}
    it "should have a real name" do
      expect(c.has_real_name?).to be true
    end
  end

  context 'disallowed word' do
    let(:name) {"fake"}
    it "should be fake" do
      expect(c.has_fake_name?).to be true
    end
  end

  context 'single letter name' do
    let(:name) {"aaaa"}
    it "should be fake" do
      expect(c.has_fake_name?).to be true
    end
  end

  context 'numbered name' do
    let(:name) {"4"}
    it "should be fake" do
      expect(c.has_fake_name?).to be true
    end
  end
end
