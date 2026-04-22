class VisitLog < ApplicationRecord
  belongs_to :user

  has_many :prescribed_medicines, dependent: :destroy
  has_many :blood_test_items, dependent: :destroy

  # ネストしたデータの保存を許可
  accepts_nested_attributes_for :prescribed_medicines, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :blood_test_items, allow_destroy: true, reject_if: :all_blank

  # 基本的な必須チェック
  validates :visited_on, presence: true
  validates :hospital_name, presence: true, length: { maximum: 100 }
  validates :department, presence: true, length: { maximum: 50 }
  validates :doctor_name, presence: true, length: { maximum: 50 }
  
  # メモの文字数制限（必要に応じて）
  validates :memo, length: { maximum: 2000 }

  # ✅ 未来の日付を許さないバリデーション（独自定義）
  validate :visited_on_cannot_be_in_the_future

  private

  def visited_on_cannot_be_in_the_future
    if visited_on.present? && visited_on > Date.today
      errors.add(:visited_on, "は今日以前の日付を選択してください")
    end
  end
end