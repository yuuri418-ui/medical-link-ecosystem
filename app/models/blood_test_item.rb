class BloodTestItem < ApplicationRecord
  belongs_to :visit_log

  validates :name, presence: true, length: { maximum: 50 }
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit, length: { maximum: 20 }
  validates :reference_range, length: { maximum: 50 }
  validates :category, length: { maximum: 30 }

  validates :visit_log, presence: true
end
