FactoryGirl.define do
  factory :space_checkpoint do
    graph JSON.generate({metrics: [], guesstimates: []})
    space
  end
end
