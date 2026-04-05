FactoryBot.define do
  factory :temperature_log do
    association :daily_log
    measured_at { Time.current }
    value { 36.5 }
  end
end