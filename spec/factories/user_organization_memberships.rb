FactoryGirl.define do
  factory :user_organization_membership do
    user
    organization
    member_type :admin
  end
end
