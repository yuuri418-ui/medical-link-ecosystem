class TemperatureLog < ApplicationRecord
  belongs_to :daily_log

  validates :value, presence: true, inclusion: { in: 30.0..45.0 }
end
