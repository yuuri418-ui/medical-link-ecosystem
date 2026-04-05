require 'rails_helper'

# ---  ---

RSpec.describe PrescribedMedicine, type: :model do
  let(:medicine) { build(:prescribed_medicine) }

  describe 'バリデーションのテスト' do
    context '全ての項目が正しく入力されている場合' do
      it '有効であること' do
        expect(medicine).to be_valid
      end
    end

    describe '必須項目と文字数制限' do
      it '薬の名前(name)がない場合は無効であること' do
        medicine.name = nil
        medicine.valid?
        expect(medicine.errors.added?(:name, :blank)).to be_truthy
      end

      it '薬の名前が100文字を超える場合は無効であること' do
        medicine.name = "あ" * 101
        medicine.valid?
        expect(medicine.errors.added?(:name, :too_long, count: 100)).to be_truthy
      end

      it '分量・飲み方(dosage)が50文字を超える場合は無効であること' do
        medicine.dosage = "あ" * 51
        medicine.valid?
        expect(medicine.errors.added?(:dosage, :too_long, count: 50)).to be_truthy
      end
    end

    describe 'アソシエーション' do
      it '受診記録(visit_log)に紐付いていない場合は無効であること' do
        medicine.visit_log = nil
        medicine.valid?
        expect(medicine.errors[:visit_log]).to be_present
      end
    end
  end
end