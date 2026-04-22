FactoryBot.define do
  factory :medication_log do
    # 親モデルである DailyLog を自動生成して紐付けます
    association :daily_log
    
    medicine_name { "プレドニン" }
    dosage { "5mg" }
    is_taken { true }
    
    # english_name は before_save で AI が設定する想定ですが、
    # テストデータとしてあらかじめ持たせておくことも可能です
    english_name { "Prednisolone" }

    # 特定の条件下（未服用など）のデータを作りたい時用のトレイト
    trait :not_taken do
      is_taken { false }
    end
  end
end