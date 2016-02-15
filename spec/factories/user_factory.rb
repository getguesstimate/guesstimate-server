FactoryGirl.define do
  factory :user do
    name 'george'
    auth0_id 'foobar'
    has_private_access false
    private_access_count 0
  end

  trait :small_plan do
    private_access_count 10
  end
end
