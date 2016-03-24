FactoryGirl.define do
  factory :organization do
    sequence(:name) { |n| "organization #{n}" }
  end
end
