FactoryGirl.define do
  factory :organization do
    sequence(:name) { |n| "organization #{n}" }
    plan :organization_free

    association :admin, factory: :user
  end
end
