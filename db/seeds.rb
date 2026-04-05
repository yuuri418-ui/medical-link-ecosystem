# 1. ユーザーの確保（全属性網羅）
user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.last_name = "デモ"; u.first_name = "ユーザー"
  u.last_name_kana = "デモ"; u.first_name_kana = "ユーザー"
  u.password = "password123"; u.password_confirmation = "password123"
  u.gender = "female"; u.birthday = Date.parse("1995-01-01")
  u.phone_number = "09012345678"; u.diagnosis_name = "関節リウマチ"
  u.started_at = Date.today - 1.year; u.patient_id = "DEMO-12345"
end

# 2. 受診記録と検査結果 (30日おきに計3回)
puts "受診記録を生成中..."
[60, 30, 0].each do |days_ago|
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

# 3. 過去90日分の詳細ログ（服薬記録以外を全て生成）
puts "90日分の体調データを生成中（服薬記録はスキップ）..."
pain_parts_list = ['head', 'hand_l', 'hand_r', 'knee_l', 'knee_r', 'shoulder_l', 'shoulder_r']

90.downto(0) do |i|
  date = Date.today - i
  next if user.daily_logs.exists?(date: date)

  is_bad_day = (rand(1..10) > 8)
  daily_log = user.daily_logs.create!(
    date: date,
    condition: is_bad_day ? rand(1..2) : rand(3..5),
    pain_vas: is_bad_day ? rand(6..9) : rand(1..3),
    fatigue_vas: is_bad_day ? rand(5..8) : rand(1..4),
    stiffness_duration: is_bad_day ? [30, 60, 120].sample : [0, 10, 15].sample,
    memo: is_bad_day ? "少し関節が痛みます。" : "体調は安定しています。",
    pain_parts: is_bad_day ? pain_parts_list.sample(rand(1..3)) : []
  )

  # 体温ログ (朝・夜)
  daily_log.temperature_logs.create!(
    measured_at: date.to_time + 8.hours, 
    value: is_bad_day ? rand(37.2..38.0).round(1) : rand(36.2..36.7).round(1)
  )
  if rand(1..2) == 2
    daily_log.temperature_logs.create!(
      measured_at: date.to_time + 20.hours, 
      value: rand(36.5..37.1).round(1)
    )
  end
  
  print "." # 進捗表示
end

puts "\nデモデータの作成が完了しました！"