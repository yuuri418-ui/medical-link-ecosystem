class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :daily_logs, dependent: :destroy
  has_many :visit_logs, dependent: :destroy

  # 性別の定義（数値と意味を紐付ける）
  enum gender: { unselected: 0, male: 1, female: 2, other: 3 }

  validates :last_name,       presence: true
  validates :first_name,      presence: true
  validates :last_name_kana,  presence: true
  validates :first_name_kana, presence: true
  validates :gender,          presence: true
  validates :birthday,        presence: true
  validates :phone_number,    presence: true
  validates :diagnosis_name,  presence: true
  validates :started_at,      presence: true

  # フリガナの形式チェック（全角カタカナのみ許可）
  VALID_KANA_REGEX = /\A[ァ-ヶー－]+\z/
  validates :last_name_kana,  format: { with: VALID_KANA_REGEX, message: "は全角カタカナで入力してください" }
  validates :first_name_kana, format: { with: VALID_KANA_REGEX, message: "は全角カタカナで入力してください" }

  # 携帯番号の形式チェック（数字のみ、10桁〜11桁など ）
  validates :phone_number, format: { with: /\A\d{10,11}\z/, message: "はハイフンなしの数字のみで入力してください" }

  # 最新の受診記録から処方薬リストを取得するメソッド
  def latest_prescribed_medicines
    visit_logs.order(visited_on: :desc).first&.prescribed_medicines || []
  end

  def name
    "#{last_name} #{first_name}"
  end
end

