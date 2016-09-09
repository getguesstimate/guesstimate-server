FactoryGirl.define do
  factory :space do
    exported_facts_count 0
    share_by_link_enabled false
    user
  end

  trait :share_by_link_enabled do
    share_by_link_enabled true
    share_by_link_token 'fakeSecureToken'
  end
end
