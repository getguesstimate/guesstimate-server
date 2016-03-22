FactoryGirl.define do
  factory :organization_space_permission do
    space
    organization
    access_type :exposed
  end
end
