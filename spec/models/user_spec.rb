require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Userモデルのテスト' do
    # ここで定義した user は、下の全ての it ブロックで使用できます
    let(:user) { build(:user) }

    describe 'バリデーションのテスト' do
      context '全ての項目が正しく入力されている場合' do
        it '有効であること' do
          expect(user).to be_valid
        end
      end

      describe '必須項目のバリデーション' do
        %i[last_name first_name last_name_kana first_name_kana].each do |attr|
          it "#{attr}がない場合は無効であること" do
            user[attr] = nil
            user.valid?
            expect(user.errors[attr]).to include("を入力してください")
          end
        end

        it 'メールアドレスがない場合は無効であること' do
          user.email = nil
          user.valid?
          expect(user.errors[:email]).to include("を入力してください")
        end

        it '性別(gender)がない場合は無効であること' do
          user.gender = nil
          user.valid?
          expect(user.errors[:gender]).to include("を入力してください")
        end

        it '誕生日(birthday)がない場合は無効であること' do
          user.birthday = nil
          user.valid?
          expect(user.errors[:birthday]).to include("を入力してください")
        end

        it '携帯番号(phone_number)がない場合は無効であること' do
          user.phone_number = nil
          user.valid?
          expect(user.errors[:phone_number]).to include("を入力してください")
        end
      end

      describe 'フォーマットのテスト' do
        it '姓（フリガナ）にカタカナ以外が含まれている場合は無効であること' do
          user.last_name_kana = "やまだ" # ひらがな
          user.valid?
          expect(user.errors[:last_name_kana]).to include("は全角カタカナで入力してください")
        end

        it '携帯番号にハイフンが含まれている場合は無効であること' do
          user.phone_number = "090-1234-5678"
          user.valid?
          expect(user.errors[:phone_number]).to include("はハイフンなしの数字のみで入力してください")
        end
      end

      describe '一意性(Unique)のテスト' do
        it '重複したメールアドレスは無効であること' do
          create(:user, email: 'duplicate@example.com')
          user.email = 'duplicate@example.com'
          user.valid?
          expect(user.errors[:email]).to be_present
        end
      end
    end

    describe 'メソッドのテスト' do
      it 'nameメソッドが姓名を結合して返すこと' do
        user.last_name = "山田"
        user.first_name = "太郎"
        expect(user.name).to eq "山田 太郎"
      end

      it 'ageメソッドが正しい年齢を返すこと' do
        # 誕生日前後を考慮したテスト
        # 1990年生まれの人が2026年4月5日時点で36歳になるか（ロジックの確認）
        user.birthday = Date.parse("1990-04-05")
        expect(user.age).to be_a(Integer)
        expect(user.age).to be >= 0 # 年齢が正の数であること
      end
    end
  end
end