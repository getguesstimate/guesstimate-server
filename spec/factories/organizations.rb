FactoryGirl.define do
  factory :organization do
    sequence(:name) { |n| "organization #{n}" }
    plan :organization_basic_30

    association :admin, factory: :user
  end
end
