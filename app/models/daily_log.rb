class DailyLog < ApplicationRecord
  belongs_to :user
  has_many :temperature_logs, dependent: :destroy
  has_many :medication_logs, dependent: :destroy

  validates :date, presence: true, uniqueness: { scope: :user_id }

  # 子要素の保存を許可し、中身が空なら無視する
  accepts_nested_attributes_for :temperature_logs, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :medication_logs, allow_destroy: true, reject_if: :all_blank
end
