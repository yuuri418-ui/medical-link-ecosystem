require 'csv'

class DailyLog < ApplicationRecord
  belongs_to :user
  has_many :temperature_logs, dependent: :destroy
  has_many :medication_logs, dependent: :destroy

  validates :date, presence: true, uniqueness: { scope: :user_id }

  # 子要素の保存を許可し、中身が空なら無視する
  accepts_nested_attributes_for :medication_logs, 
    allow_destroy: true, 
    reject_if: proc { |attributes| attributes['medicine_name'].blank? }

  accepts_nested_attributes_for :temperature_logs, 
    allow_destroy: true, 
    reject_if: proc { |attributes| attributes['value'].blank? }

    # ✅ 部位名の辞書定義（シェーマで使用しているIDと日本語名のペア）
  PAIN_PART_LABELS = {
    'head' => '頭部',
    'neck' => '首',
    'shoulder_l' => '左肩',
    'shoulder_r' => '右肩',
    'elbow_l' => '左肘',
    'elbow_r' => '右肘',
    'hand_l' => '左手',
    'hand_r' => '右手',
    'left_wrist'  => '左手首',
    'right_wrist' => '右手首',
    'left_fingers'  => '左手の指',
    'right_fingers' => '右手の指',
    'left_ankle'  => '左足首',
    'right_ankle' => '右足首',
    'chest' => '胸部',
    'stomach' => '腹部',
    'back' => '背中',
    'waist' => '腰',
    'hip_l' => '左股関節',
    'hip_r' => '右股関節',
    'knee_l' => '左膝',
    'knee_r' => '右膝',
    'foot_l' => '左足',
    'foot_r' => '右足',
    'left_hip' => '左股関節', 
    'right_hip' => '右股関節'  
  }.freeze

  # ✅ 配列内の英語を日本語に一括変換するメソッド
  def pain_parts_jp
    return [] if pain_parts.blank?
    
    # 文字列なら配列に戻す
    parts = pain_parts.is_a?(String) ? (JSON.parse(pain_parts) rescue []) : pain_parts
    
    # 辞書を使って変換（見つからない場合は元の英語を出す）
    parts.map { |part| PAIN_PART_LABELS[part] || part }
  end

  def self.to_csv
    # 出力したい基本項目
    main_columns = %w[date condition pain_vas fatigue_vas stiffness_duration memo]
    
    CSV.generate(headers: true) do |csv|
      # ヘッダー作成
      header = main_columns.map { |col| I18n.t("activerecord.attributes.daily_log.#{col}", default: col.humanize) }
      header << "体温記録(時間:度)"
      header << "痛む部位(シェーマ)" # ✅ 項目を追加
      csv << header
      
      all.order(date: :desc).each do |log|
        # 1. 体温データの整形
        temp_strings = log.temperature_logs.order(:measured_at).map do |t|
          time = t.measured_at&.in_time_zone('Tokyo')&.strftime("%H:%M") || "--:--"
          "#{time}(#{t.value}℃)"
        end
        temp_display = temp_strings.join(" / ")

        # ✅ 2. 痛む部位 (pain_parts) の整形
        # pain_parts は JSON 形式なので、そこから部位名を取り出します
        # データの入り方（[{"part": "右肩"}, ...] など）に合わせて調整が必要ですが、
        # 一般的な実装を想定したコードです：
        pain_parts_display = if log.pain_parts.present?
                               # JSON内の各要素から名前（仮に "name" や "part"）を取り出す
                               # ※もし単純な配列 ["右肩", "左膝"] なら log.pain_parts.join(", ") でOK
                               begin
                                 parts = log.pain_parts
                                 parts.is_a?(Array) ? parts.join("、") : parts
                               rescue
                                 "データ形式エラー"
                               end
                             else
                               "なし"
                             end
        
        # 行データを作成
        row = main_columns.map { |col| log.send(col) }
        row << temp_display      # 体温
        row << pain_parts_display # ✅ 痛む部位
        
        csv << row
      end
    end
  end
end
