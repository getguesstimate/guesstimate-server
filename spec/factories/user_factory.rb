FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "user #{n}" }
    sequence(:username) { |n| "username #{n}" }
    sequence(:email) { |n| "email_#{n}@email.com" }
    sequence(:auth0_id) { |n| "auth0_id #{n}" }
    plan :personal_free
  end

  trait :lite_plan do
    plan :personal_lite
  end

  trait :premium_plan do
    plan :personal_premium
  end
end
