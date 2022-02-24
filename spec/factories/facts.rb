FactoryBot.define do
  factory :fact do
    name { 'name' }
    sequence(:variable_name) { |n| "variable_#{n}" }
    expression { '100' }
    simulation { {"sample" => { "values" => [1], "errors" => [] }, "stats" => { "mean" => 1, "stdev" => 0, "length" => 1 }} }

    organization
  end
end
