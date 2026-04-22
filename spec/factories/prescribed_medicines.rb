FactoryBot.define do
  factory :prescribed_medicine do
    association :visit_log
    name { "ロキソニン" }
    dosage { "1日3回 毎食後" }
  end
end