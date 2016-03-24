FactoryGirl.define do
  factory :space do
    association :creator, factory: :user
  end
end
