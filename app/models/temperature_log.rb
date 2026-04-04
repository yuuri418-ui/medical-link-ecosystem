class TemperatureLog < ApplicationRecord
  belongs_to :daily_log

  validates :value, presence: true, inclusion: { in: 30.0..45.0 }
  validates :measured_at, presence: true

  validate :measured_at_cannot_be_in_the_future

  private

  def measured_at_cannot_be_in_the_future
    if measured_at.present? && measured_at > Time.current
      errors.add(:measured_at, "は現在時刻以前を選択してください")
    end
  end
end
