FactoryBot.define do
  factory :visit_log do
    association :user # 自動的にUserを作成して紐付けます
    visited_on { Date.today }
    hospital_name { "中央総合病院" }
    department { "内科" }
    doctor_name { "山田先生" }
    memo { "今日は体調が良かった。" }
  end
end