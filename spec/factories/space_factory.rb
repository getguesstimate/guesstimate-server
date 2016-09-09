FactoryGirl.define do
  factory :space do
    exported_facts_count 0
    shareable_link_enabled false
    user
  end

  trait :shareable_link_enabled do
    shareable_link_enabled true
    shareable_link_token 'fakeSecureToken'
  end
end
