class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 性別の定義（数値と意味を紐付ける）
  enum gender: { unselected: 0, male: 1, female: 2, other: 3 }
end

