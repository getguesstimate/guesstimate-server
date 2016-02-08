require 'rails_helper'

RSpec.describe Space, type: :model do
  it {is_expected.to validate_presence_of(:user_id) }
end
