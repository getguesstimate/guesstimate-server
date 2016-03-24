FactoryGirl.define do
  factory :user_space_permission do
    space
    user
    access_type 1
  end
end
