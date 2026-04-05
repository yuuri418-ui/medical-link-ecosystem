FactoryBot.define do
  factory :daily_log do
    association :user
    date { Date.today }
    stiffness_duration { 10 }
    pain_vas { 3 }
    fatigue_vas { 2 }
    condition { 3 }
    memo { "テスト用のメモです。" }
    pain_parts { [] }
  end
end