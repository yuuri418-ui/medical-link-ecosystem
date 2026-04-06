# 1. ユーザーの確保
# addressは空のまま（nil）で作成します
user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.last_name = "デモ"; u.first_name = "ユーザー"
  u.last_name_kana = "デモ"; u.first_name_kana = "ユーザー"
  u.password = "password123"; u.password_confirmation = "password123"
  u.gender = "female"; u.birthday = Date.parse("1995-01-01")
  u.phone_number = "09012345678"; u.diagnosis_name = "関節リウマチ"
  u.started_at = Date.today - 1.year; u.patient_id = "DEMO-12345"
  # addressはあえて指定しません
end

# 2. 薬のマスターデータ（英語名もセット）
# ※english_name カラムがある前提です。もしカラム名が異なる場合は適宜修正してください。
medicines_data = [
  { name: "メトトレキサート", english_name: "Methotrexate", dosage: "8mg" },
  { name: "プレドニン", english_name: "Prednisolone", dosage: "5mg" }
]

# 3. 受診記録と検査結果 (30日おきに計6回分に増やしました)
puts "受診記録を生成中..."
[150, 120, 90, 60, 30, 0].each do |days_ago|
  v_date = Date.today - days_ago
  next if user.visit_logs.exists?(visited_on: v_date)

  visit = user.visit_logs.create!(
    visited_on: v_date, hospital_name: "中央総合病院", department: "リウマチ科", 
    doctor_name: "山田先生", memo: days_ago == 0 ? "本日の定期受診。" : "定期受診。"
  )
  visit.blood_test_items.create!([
    { name: "CRP", value: [0.05, 0.15, 0.2].sample, unit: "mg/dL", reference_range: "0.14以下", category: "炎症" },
    { name: "WBC", value: rand(4000..7000), unit: "/μL", reference_range: "3300-8600", category: "血算" },
    { name: "MMP-3", value: rand(30..55), unit: "ng/mL", reference_range: "17.3-59.7", category: "関節破壊指標" }
  ])
  visit.prescribed_medicines.create!([
    { name: "メトトレキサート", dosage: "8mg/週" }, { name: "プレドニン", dosage: "5mg/日" }
  ])
end

# 4. 過去180日分の詳細ログ（体調・体温・★服薬記録）
puts "180日分の体調データと【服薬記録】を生成中..."
pain_parts_list = ['head', 'hand_l', 'hand_r', 'knee_l', 'knee_r', 'shoulder_l', 'shoulder_r']

180.downto(0) do |i|
  date = Date.today - i
  
  # DailyLogを探すか作成
  daily_log = user.daily_logs.find_or_create_by!(date: date) do |log|
    is_bad_day = (rand(1..10) > 8)
    log.condition = is_bad_day ? rand(1..2) : rand(3..5)
    log.pain_vas = is_bad_day ? rand(6..9) : rand(1..3)
    log.fatigue_vas = is_bad_day ? rand(5..8) : rand(1..4)
    log.stiffness_duration = is_bad_day ? [30, 60, 120].sample : [0, 10, 15].sample,
    log.memo = is_bad_day ? "少し関節が痛みます。" : "体調は安定しています。"
    log.pain_parts = is_bad_day ? pain_parts_list.sample(rand(1..3)) : []
  end

  # 体温ログ (朝・夜)
  unless daily_log.temperature_logs.exists?
    daily_log.temperature_logs.create!(
      measured_at: date.to_time + 8.hours, 
      value: (rand(1..10) > 8) ? rand(37.2..37.8).round(1) : rand(36.2..36.7).round(1)
    )
  end
  
  # ★★★ 服薬記録 (MedicationLog) ★★★
  unless daily_log.medication_logs.exists?
    medicines_data.each do |med|
      daily_log.medication_logs.create!(
        name: med[:name],
        english_name: med[:english_name],
        dosage: med[:dosage],
        taken_at: date.to_time + 9.hours
      )
    end
  end
  
  print "■" if i % 10 == 0 # 10日ごとに進捗表示
end

puts "\n180日分のデモデータの作成が完了しました！"