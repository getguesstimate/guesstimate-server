FactoryBot.define do
  factory :calculator do
    content { "MyText" }
    title { "MyTitle" }
    input_ids { ["1"] }
    output_ids { ["2"] }

    space
  end
end
