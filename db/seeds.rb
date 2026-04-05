return if DailyLog.exists?(user_id: User.find_by(email: "demo@example.com")&.id)
# 既存データのクリア（必要に応じて）
puts "データをクリーニング中..."

BloodTestResult.destroy_all if defined?(BloodTestResult)
BloodTestItem.destroy_all if defined?(BloodTestItem)

PrescribedMedicine.destroy_all
TemperatureLog.destroy_all
MedicationLog.destroy_all

# 2. 次にその「親」を消す
VisitLog.destroy_all
DailyLog.destroy_all

# 3. 最後に「最上位の親」を消す
User.destroy_all

puts "クリーニング完了。デモデータを生成します..."

# 1. デモユーザーの作成
user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.last_name = "デモ"         # 姓
  u.first_name = "ユーザー"     # 名
  u.last_name_kana = "デモ"    # 姓カナ (実際はバリデーションに合わせてカタカナが望ましい)
  u.first_name_kana = "ユーザー"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.gender = "female"
  u.birthday = Date.parse("1995-01-01")
  u.phone_number = "09012345678"
  u.diagnosis_name = "関節リウマチ"
  u.started_at = Date.today - 1.year
  u.patient_id = "DEMO-12345"
end

# 2. 受診記録と検査結果の生成 (30日おきに受診)
puts "受診記録と検査結果を生成中..."
[60, 30, 0].each do |days_ago|
  v_date = Date.today - days_ago
  visit = user.visit_logs.create!(
    visited_on: v_date,
    hospital_name: "中央総合病院",
    department: "リウマチ科",
    doctor_name: "山田先生",
    memo: days_ago == 0 ? "本日の定期受診。数値は安定しているとのこと。" : "定期受診。薬の量を調整。"
  )

  # 血液検査結果の追加
  visit.blood_test_items.create!([
    { name: "CRP", value: [0.05, 0.12, 0.25].sample, unit: "mg/dL", reference_range: "0.14以下", category: "炎症" },
    { name: "WBC", value: rand(4000..8000), unit: "/μL", reference_range: "3300-8600", category: "血算" },
    { name: "MMP-3", value: rand(30..60), unit: "ng/mL", reference_range: "17.3-59.7", category: "関節破壊指標" }
  ])

  # 処方薬の追加
  visit.prescribed_medicines.create!([
    { name: "メトトレキサート", dosage: "8mg/週" },
    { name: "プレドニン", dosage: "5mg/日" },
  ])
end

# 3. 過去90日分（約3ヶ月分）の体調データを生成
puts "90日分のデモデータを生成中..."

pain_parts_list = ['head', 'hand_l', 'hand_r', 'knee_l', 'knee_r', 'shoulder_l', 'shoulder_r']

90.downto(0) do |i|
  date = Date.today - i
  
  # 少しリアルな「体調の波」を作る
  is_bad_day = (rand(1..10) > 8)

  daily_log = user.daily_logs.create!(
    date: date,
    condition: is_bad_day ? rand(1..2) : rand(3..5),
    pain_vas: is_bad_day ? rand(6..9) : rand(1..3),
    fatigue_vas: is_bad_day ? rand(5..8) : rand(1..4),
    stiffness_duration: is_bad_day ? [30, 60, 120].sample : [0, 10, 15].sample,
    memo: is_bad_day ? "今日は少し関節が痛む。無理せず過ごす。" : "体調は安定している。",
    pain_parts: is_bad_day ? pain_parts_list.sample(rand(1..3)) : []
  )

  # 体温データの生成 (1日1〜2回)
  daily_log.temperature_logs.create!(
    measured_at: date.to_time + 8.hours, # 朝8時
    value: is_bad_day ? rand(37.0..38.2).round(1) : rand(36.2..36.8).round(1)
  )
  if rand(1..2) == 2
    daily_log.temperature_logs.create!(
      measured_at: date.to_time + 20.hours, # 夜20時
      value: rand(36.5..37.2).round(1)
    )
  end

  # 服薬チェックデータの生成 
  # --- 90.downto(0) のループの中身 ---
  meds = [
    { name: "メトトレキサート", dose: "8mg" },
    { name: "プレドニン", dose: "5mg" }
  ]

  meds.each do |med|
    success = false
    retry_count = 0

    until success || retry_count >= 5
      begin
        log = daily_log.medication_logs.create!(
          medicine_name: med[:name],
          dosage: med[:dose],
          is_taken: true
        )

        if log.english_name.present?
          success = true
          print "o"
          sleep rand(1.5..3.0)
        else
          log.destroy
          raise "English name is empty"
        end
      rescue => e
        retry_count += 1
        wait_time = 20 + (retry_count * 10)
        puts "\n[Retry #{retry_count}] 翻訳失敗: #{e.message}"
        sleep wait_time
        retry if retry_count < 5
      end
    end # until の end
  end   # meds.each の end
end     



puts "デモデータの作成が完了しました！"
puts "-----------------------------------"
puts "ログイン用メールアドレス: demo@example.com"
puts "パスワード: password123"
puts "受診記録: #{VisitLog.count}件"
puts "デイリーログ: #{DailyLog.count}件"
puts "-----------------------------------"