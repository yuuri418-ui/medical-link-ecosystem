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

  def age
    return "不明" if birthday.blank?
    
    # 現在の年月日(20260404)から生年月日(19950101)を引いて10000で割る
    # これで誕生日前後を考慮した正確な年齢が算出できます
    date_format = "%Y%m%d"
    current_date = Time.zone.now.strftime(date_format).to_i
    birth_date = birthday.strftime(date_format).to_i
    
    (current_date - birth_date) / 10000
  end
end

