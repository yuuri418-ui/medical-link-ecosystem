# 1. ユーザーの確保
user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.last_name = "デモ"; u.first_name = "ユーザー"
  u.last_name_kana = "デモ"; u.first_name_kana = "ユーザー"
  u.password = "password123"; u.password_confirmation = "password123"
  u.gender = "female"; u.birthday = Date.parse("1995-01-01")
  u.phone_number = "09012345678"; u.diagnosis_name = "関節リウマチ"
  u.started_at = Date.today - 1.year; u.patient_id = "DEMO-12345"
end

# 2. マスターデータ
medicines_data = [
  { medicine_name: "メトトレキサート", english_name: "Methotrexate", dosage: "8mg" },
  { medicine_name: "プレドニン", english_name: "Prednisolone", dosage: "5mg" }
]
pain_parts_list = ['head', 'left_shoulder', 'right_shoulder', 'left_elbow', 'right_elbow', 'hand_l', 'hand_r', 'left_knee', 'right_knee', 'left_ankle', 'right_ankle', 'abdomen']

# --- 受診記録と血液検査データの生成 (30日おきに6回分) ---
puts "受診記録と血液検査データを生成中..."
[150, 120, 90, 60, 30, 0].each_with_index do |days_ago, index|
  v_date = Date.today - days_ago
  # 重複防止
  next if user.visit_logs.exists?(visited_on: v_date)

  visit = user.visit_logs.build(
    visited_on: v_date,
    hospital_name: "中央総合病院",
    department: "リウマチ科",
    doctor_name: "山田先生",
    memo: index == 5 ? "本日の定期受診。体調の波があることを相談。" : "定期受診。経過観察。"
  )
  visit.save(validate: false)

  # 血液検査データの追加（徐々に改善、または波がある設定）
  # CRP: 炎症の指標（高いと悪い）
  crp_value = [0.8, 1.2, 0.5, 0.9, 0.2, 0.15][index] 
  # MMP-3: 関節破壊の指標
  mmp3_value = [85, 70, 65, 75, 50, 45][index]

  visit.blood_test_items.build([
    { name: "CRP", value: crp_value, unit: "mg/dL", reference_range: "0.14以下", category: "炎症" },
    { name: "MMP-3", value: mmp3_value, unit: "ng/mL", reference_range: "17.3-59.7", category: "関節破壊指標" },
    { name: "WBC", value: rand(4000..8000), unit: "/μL", reference_range: "3300-8600", category: "血算" }
  ]).each { |item| item.save(validate: false) }
end

# --- 180日分の体調ログ生成 (以前のロジックを継続) ---
good_memos = ["体調は安定しています。", "今日は調子が良いです。", "散歩に行けました。"]
slight_fever_memos = ["少し体が熱っぽいです。", "微熱がありますが、動けます。", "大事をとって早めに休みます。"]
bad_memos = ["高熱が出て関節がひどく痛みます。", "動くのが辛く、一日横になっています。", "炎症が強い感じがします。"]
bad_days_remaining = 0

puts "180日分の体調・服薬ストーリーを生成中..."
180.downto(0) do |i|
  date = Date.today - i
  next if user.daily_logs.exists?(date: date)

  if bad_days_remaining > 0
    status = :very_bad; bad_days_remaining -= 1
  elsif (i % 30 == 15)
    status = :very_bad; bad_days_remaining = 2
  elsif rand(1..4) == 1
    status = :slight_fever
  else
    status = :good
  end

  case status
  when :very_bad
    cond, p_vas, f_vas, temp = rand(1..2), rand(7..9), rand(7..9), rand(37.8..38.5).round(1)
    stiffness, memo, parts = [120, 180, 240].sample, bad_memos.sample, pain_parts_list.sample(rand(3..5))
  when :slight_fever
    cond, p_vas, f_vas, temp = 3, rand(3..5), rand(4..6), rand(37.0..37.4).round(1)
    stiffness, memo, parts = [30, 45, 60].sample, slight_fever_memos.sample, pain_parts_list.sample(rand(1..2))
  else
    cond, p_vas, f_vas, temp = rand(4..5), rand(1..2), rand(1..3), rand(36.2..36.8).round(1)
    stiffness, memo, parts = [0, 5, 10].sample, good_memos.sample, []
  end

  daily_log = user.daily_logs.build(date: date, condition: cond, pain_vas: p_vas, fatigue_vas: f_vas, stiffness_duration: stiffness, memo: memo, pain_parts: parts)
  daily_log.save(validate: false)

  medicines_data.each do |med|
    daily_log.medication_logs.build(medicine_name: med[:medicine_name], english_name: med[:english_name], dosage: med[:dosage], is_taken: true).save(validate: false)
  end
  daily_log.temperature_logs.build(measured_at: date.to_time + 8.hours, value: temp).save(validate: false)
  
  print "■" if i % 10 == 0
end
puts "\nすべて完了しました！"