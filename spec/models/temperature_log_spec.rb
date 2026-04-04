require 'rails_helper'

RSpec.describe TemperatureLog, type: :model do
  let(:temp_log) { build(:temperature_log) }

  describe 'バリデーションのテスト' do
    context '全ての項目が正しく入力されている場合' do
      it '有効であること' do
        expect(temp_log).to be_valid
      end
    end

    describe '必須項目と値の範囲制限' do
      it '体温(value)がない場合は無効であること' do
        temp_log.value = nil
        temp_log.valid?
        expect(temp_log.errors.added?(:value, :blank)).to be_truthy
      end

      it '体温が30.0度未満(29.9)の場合は無効であること' do
        temp_log.value = 29.9
        temp_log.valid?
        expect(temp_log.errors.added?(:value, :inclusion, value: 29.9)).to be_truthy
      end

      it '体温が45.0度を超える(45.1)の場合は無効であること' do
        temp_log.value = 45.1
        temp_log.valid?
        expect(temp_log.errors.added?(:value, :inclusion, value: 45.1)).to be_truthy
      end

      it '測定時刻(measured_at)がない場合は無効であること' do
        temp_log.measured_at = nil
        temp_log.valid?
        expect(temp_log.errors.added?(:measured_at, :blank)).to be_truthy
      end
    end

    describe '形式・独自ルールのテスト' do
      it '未来の時刻（1時間後）の場合は無効であること' do
        temp_log.measured_at = 1.hour.from_now
        temp_log.valid?
        expect(temp_log.errors[:measured_at]).to be_present
      end
    end

    describe 'アソシエーション' do
      it 'DailyLogに紐付いていない場合は無効であること' do
        temp_log.daily_log = nil
        temp_log.valid?
        expect(temp_log.errors[:daily_log]).to be_present
      end
    end
  end
end