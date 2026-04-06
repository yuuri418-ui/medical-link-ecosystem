# 1. ユーザーの確保（住所なし、空OK設定を活かします）
user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.last_name = "デモ"; u.first_name = "ユーザー"
  u.last_name_kana = "デモ"; u.first_name_kana = "ユーザー"
  u.password = "password123"; u.password_confirmation = "password123"
  u.gender = "female"; u.birthday = Date.parse("1995-01-01")
  u.phone_number = "09012345678"; u.diagnosis_name = "関節リウマチ"
  u.started_at = Date.today - 1.year; u.patient_id = "DEMO-12345"
end

# 2. 薬のデータ（カラム名に合わせて修正済み）
medicines_data = [
  { medicine_name: "メトトレキサート", english_name: "Methotrexate", dosage: "8mg" },
  { medicine_name: "プレドニン", english_name: "Prednisolone", dosage: "5mg" }
]

# 3. 受診記録と検査結果
puts "受診記録を生成中..."
[150, 120, 90, 60, 30, 0].each do |days_ago|
  v_date = Date.today - days_ago
  next if user.visit_logs.exists?(visited_on: v_date)
  visit = user.visit_logs.create!(visited_on: v_date, hospital_name: "中央総合病院", department: "リウマチ科", doctor_name: "山田先生")
end

# 4. 180日分の体調データ ＋ 【服薬記録】 を生成
puts "180日分のデータを生成中（服薬記録：medicine_nameを使用）..."
pain_parts_list = ['hand_l', 'hand_r', 'knee_l', 'knee_r', 'shoulder_l', 'shoulder_r']

180.downto(0) do |i|
  date = Date.today - i
  # 以前のユーザーを破壊済みなので、すべてのデータが新しく作られます
  daily_log = user.daily_logs.create!(
    date: date,
    condition: rand(3..5),
    pain_vas: rand(1..3),
    fatigue_vas: rand(1..4),
    stiffness_duration: [0, 10, 15].sample,
    memo: "体調は安定しています。",
    pain_parts: (rand(1..10) > 8) ? pain_parts_list.sample(rand(1..2)) : []
  )

  # ★ 服薬ログを1日ずつ確実に、正しいカラム名（medicine_name）で入れる
  medicines_data.each do |med|
    daily_log.medication_logs.create!(
      medicine_name: med[:medicine_name],
      english_name: med[:english_name],
      dosage: med[:dosage],
      is_taken: true # 服用済みフラグもセット
    )
  end

  # 体温ログ
  daily_log.temperature_logs.create!(measured_at: date.to_time + 8.hours, value: rand(36.2..36.8).round(1))
  
  print "■" if i % 10 == 0
end

puts "\n180日分のデモデータの作成が完了しました！"