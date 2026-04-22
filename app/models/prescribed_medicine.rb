class PrescribedMedicine < ApplicationRecord
  belongs_to :visit_log

  validates :name, presence: true, length: { maximum: 100 }
  validates :dosage, length: { maximum: 50 }

  validates :visit_log, presence: true
end
