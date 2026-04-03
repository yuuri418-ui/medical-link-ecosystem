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
end
