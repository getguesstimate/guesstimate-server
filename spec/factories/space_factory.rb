FactoryBot.define do
  factory :space do
    exported_facts_count 0
    shareable_link_enabled false
    user
  end

  trait :shareable_link_enabled do
    is_private true
    shareable_link_enabled true
    shareable_link_token 'fakeSecureToken--------------------' # Padded to be > 32 characters, for validation limit.

    association :user, :lite_plan
  end
end
