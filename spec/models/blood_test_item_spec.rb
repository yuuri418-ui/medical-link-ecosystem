require 'rails_helper'

RSpec.describe BloodTestItem, type: :model do
  let(:blood_test_item) { build(:blood_test_item) }

  describe 'バリデーションのテスト' do
    context '全ての項目が正しく入力されている場合' do
      it '有効であること' do
        expect(blood_test_item).to be_valid
      end
    end

    describe '必須項目と数値の制限' do
      it '項目名(name)がない場合は無効であること' do
        blood_test_item.name = nil
        blood_test_item.valid?
        expect(blood_test_item.errors.added?(:name, :blank)).to be_truthy
      end

      it '値(value)がない場合は無効であること' do
        blood_test_item.value = nil
        blood_test_item.valid?
        expect(blood_test_item.errors.added?(:value, :blank)).to be_truthy
      end

      it '値(value)が負の数値の場合は無効であること' do
        blood_test_item.value = -0.1
        blood_test_item.valid?
        expect(blood_test_item.errors.added?(:value, :greater_than_or_equal_to, value: -0.1, count: 0)).to be_truthy
      end

      it '値(value)が数値以外（文字列）の場合は無効であること' do
        blood_test_item.value = "A"
        blood_test_item.valid?
        expect(blood_test_item.errors.added?(:value, :not_a_number, value: "A")).to be_truthy
      end
    end

    describe 'アソシエーション' do
      it '受診記録(visit_log)に紐付いていない場合は無効であること' do
        blood_test_item.visit_log = nil
        blood_test_item.valid?
        expect(blood_test_item.errors[:visit_log]).to be_present
      end
    end
  end
end