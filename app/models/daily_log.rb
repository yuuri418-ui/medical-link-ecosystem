class DailyLog < ApplicationRecord
  belongs_to :user
  has_many :temperature_logs, dependent: :destroy

  validates :date, presence: true, uniqueness: { scope: :user_id }
end
