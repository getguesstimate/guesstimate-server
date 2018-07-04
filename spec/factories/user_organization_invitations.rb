FactoryBot.define do
  factory :user_organization_invitation do
    sequence(:email) { |n| "email_#{n}@email.com" }

    organization
  end
end
