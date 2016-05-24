FactoryGirl.define do
  factory :organization do
    sequence(:name) { |n| "organization #{n}" }

    association :admin, factory: :user
  end
end
