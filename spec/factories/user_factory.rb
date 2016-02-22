FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user #{n}" }
    sequence(:auth0_id) { |n| "auth0_id #{n}" }
    has_private_access false
    private_access_count 0
  end

  trait :small_plan do
    has_private_access true
    private_access_count 10
  end
end
