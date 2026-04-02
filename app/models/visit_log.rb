class VisitLog < ApplicationRecord
  belongs_to :user

  has_many :blood_test_results, dependent: :destroy
  has_many :prescribed_medicines, dependent: :destroy
  has_many :blood_test_items, dependent: :destroy

  # ネストしたデータの保存を許可
  accepts_nested_attributes_for :blood_test_results, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :prescribed_medicines, allow_destroy: true, reject_if: :all_blank

  validates :visited_on, presence: true
  validates :hospital_name, presence: true
  validates :department, presence: true
  validates :doctor_name, presence: true
end

