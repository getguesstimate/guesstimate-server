require 'rails_helper'

VALID_NAMES = ['Real Model', 'Test aaaa still real']
INVALID_NAMES = ['test', 'test4', '4', 'aaaa', 'ha', '', 'test aaa ha']

describe 'fake names' do
  let(:dummy_class) {
    Class.new {
      include FakeNameDetector
      def initialize(name)
        @name = name
      end
      attr_reader :name
    }
  }
  subject(:klass) { dummy_class.new(name) }

  VALID_NAMES.each do |name|
    context 'with valid name' do
      let(:name) {name}
      it 'should have a real name' do
        expect(klass.has_real_name?).to be true
      end
    end
  end

  INVALID_NAMES.each do |name|
    context 'with invalid name' do
      let(:name) {name}
      it 'should be fake' do
        expect(klass.has_fake_name?).to be true
      end
    end
  end

  context 'with cased name' do
    cased_name = "This NaMe HAS weird Cases."
    let(:name) {cased_name.clone}

    it 'should not modify klass.name' do
      # Trigger the functionality.
      klass.has_real_name?

      expect(klass.name).to eq cased_name
    end
  end
end
