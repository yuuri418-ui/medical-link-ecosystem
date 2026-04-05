FactoryBot.define do
  factory :blood_test_item do
    association :visit_log
    name { "CRP" }
    value { 0.05 }
    unit { "mg/dL" }
    reference_range { "0.14以下" }
    category { "炎症反応" }
  end
end