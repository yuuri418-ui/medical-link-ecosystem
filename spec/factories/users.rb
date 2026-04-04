FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    last_name { "山田" }
    first_name { "太郎" }
    last_name_kana { "ヤマダ" }
    first_name_kana { "タロウ" }

    gender { 1 }
    birthday { Date.parse("1990-01-01") }
    # ✅ 修正：ハイフンを抜き、数字のみにします
    phone_number { "09012345678" }

    # 任意項目
    diagnosis_name { "全身性エリテマトーデス" }
    started_at { Date.parse("2024-04-01") }
    patient_id { "AB1234567" }
  end
end