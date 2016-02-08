require 'rails_helper'

RSpec.describe User, type: :model do
    it { is_expected.to validate_numericality_of(:private_access_count) }
    it { should_not allow_value(-1).for(:private_access_count) }
    it { should allow_value(0).for(:private_access_count) }
end
