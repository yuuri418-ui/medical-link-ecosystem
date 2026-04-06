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
pain_parts_list = ['hand_l', 'hand_r', 'knee_l', 'knee_r', 'shoulder_l', 'shoulder_r', 'foot_l', 'foot_r']

# メモのバリエーション
good_memos = ["体調は安定しています。", "今日は調子が良いです。", "散歩に行けました。"]
slight_fever_memos = ["少し体が熱っぽいです。", "微熱がありますが、動けます。", "大事をとって早めに休みます。"]
bad_memos = ["高熱が出て関節がひどく痛みます。", "動くのが辛く、一日横になっています。", "炎症が強い感じがします。"]

# 状態管理用の変数
bad_days_remaining = 0

# 3. 180日分のデータを生成
puts "ストーリー性のある180日分のデータを生成中..."

180.downto(0) do |i|
  date = Date.today - i
  next if user.daily_logs.exists?(date: date)

  # --- 体調判定ロジック ---
  # 30日周期の開始判定、または継続判定
  if bad_days_remaining > 0
    # 連続不調の継続
    status = :very_bad
    bad_days_remaining -= 1
  elsif (i % 30 == 15) # 30日ごとに不調フラグを立てる（例：15日目、45日目...）
    status = :very_bad
    bad_days_remaining = 2 # 今日を含めて合計3日間
  elsif rand(1..4) == 1 # 残りの日のうち、約25%（週1.7日＝月約7日）を微熱に
    status = :slight_fever
  else
    status = :good
  end

  # パラメータ設定
  case status
  when :very_bad
    cond = rand(1..2)
    p_vas = rand(7..9)
    f_vas = rand(7..9)
    temp = rand(37.8..38.5).round(1)
    stiffness = [120, 180, 240].sample
    memo = bad_memos.sample
    parts = pain_parts_list.sample(rand(3..5))
  when :slight_fever
    cond = 3
    p_vas = rand(3..5)
    f_vas = rand(4..6)
    temp = rand(37.0..37.4).round(1)
    stiffness = [30, 45, 60].sample
    memo = slight_fever_memos.sample
    parts = pain_parts_list.sample(rand(1..2))
  else
    cond = rand(4..5)
    p_vas = rand(1..2)
    f_vas = rand(1..3)
    temp = rand(36.2..36.8).round(1)
    stiffness = [0, 5, 10].sample
    memo = good_memos.sample
    parts = []
  end

  # 保存実行
  daily_log = user.daily_logs.build(
    date: date, condition: cond, pain_vas: p_vas, fatigue_vas: f_vas,
    stiffness_duration: stiffness, memo: memo, pain_parts: parts
  )
  daily_log.save(validate: false)

  # 服薬・体温
  medicines_data.each do |med|
    daily_log.medication_logs.build(medicine_name: med[:medicine_name], english_name: med[:english_name], dosage: med[:dosage], is_taken: true).save(validate: false)
  end
  daily_log.temperature_logs.build(measured_at: date.to_time + 8.hours, value: temp).save(validate: false)
  
  print "■" if i % 10 == 0
end
puts "\n180日分のストーリーデータが完成しました！"