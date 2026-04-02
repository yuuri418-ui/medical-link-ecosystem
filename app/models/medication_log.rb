class MedicationLog < ApplicationRecord
  belongs_to :daily_log

  validates :medicine_name, presence: true
end
