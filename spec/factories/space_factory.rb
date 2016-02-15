FactoryGirl.define do
  factory :space do
    name 'cool space'
    graph {}
    is_private false
  end

  #trait :with_three_private_spaces do
  #end
end
