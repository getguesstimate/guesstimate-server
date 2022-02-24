FactoryBot.define do
  factory :fact_checkpoint do
    simulation {JSON.generate sample: {values: [1], errors: []}, stats: {mean: 1, stdev: 0, length: 1}}

    fact
    association :author, :factory => :user
  end
end
