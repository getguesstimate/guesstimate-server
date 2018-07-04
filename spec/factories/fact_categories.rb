FactoryBot.define do
  factory :fact_category do
    sequence(:name) { |n| "category #{n}" }

    organization
  end
end
