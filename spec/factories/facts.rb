FactoryGirl.define do
  factory :fact do
    name 'name'
    sequence(:variable_name) { |n| "variable_#{n}" }
    expression '100'

    organization
  end
end
