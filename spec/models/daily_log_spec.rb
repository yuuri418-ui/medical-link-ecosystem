require 'rails_helper'

RSpec.describe DailyLog, type: :model do
  describe '体調記録のバリデーションテスト' do
    let(:user) { create(:user) }
    let(:daily_log) { build(:daily_log, user: user) }

    context '全ての項目が正しく入力されている場合' do
      it '有効であること' do
        expect(daily_log).to be_valid
      end
    end

    describe '必須項目と一意性のバリデーション' do
      it '日付(date)がない場合は無効であること' do
        daily_log.date = nil
        daily_log.valid?
        expect(daily_log.errors.added?(:date, :blank)).to be_truthy
      end

      it '同じユーザーが同じ日付で2回登録することはできないこと' do
        create(:daily_log, user: user, date: daily_log.date)
        daily_log.valid?
        expect(daily_log.errors.added?(:date, :taken, value: daily_log.date)).to be_truthy
      end

      it '体調(condition)がない場合は無効であること' do
        daily_log.condition = nil
        daily_log.valid?
        expect(daily_log.errors.added?(:condition, :blank)).to be_truthy
      end
    end

    describe '数値の範囲・形式制限' do
      it '体調(condition)が1〜5の範囲外(6)の場合は無効であること' do
        daily_log.condition = 6
        daily_log.valid?
        expect(daily_log.errors.added?(:condition, :inclusion, value: 6)).to be_truthy
      end

      it '痛みVASが0〜10の範囲外(-1)の場合は無効であること' do
        daily_log.pain_vas = -1
        daily_log.valid?
        expect(daily_log.errors.added?(:pain_vas, :inclusion, value: -1)).to be_truthy
      end

      it '未来の日付（明日）の場合は無効であること' do
        daily_log.date = Date.tomorrow
        daily_log.valid?
        expect(daily_log.errors[:date]).to be_present
      end
    end

    describe 'カスタムメソッドのテスト' do
      it 'pain_parts_jpメソッドが英語の部位名を日本語に変換して返すこと' do
        daily_log.pain_parts = ['head', 'knee_l']
        expect(daily_log.pain_parts_jp).to eq ['頭部', '左膝']
      end

      it '辞書にない部位名の場合はそのままの文字列を返すこと' do
        daily_log.pain_parts = ['unknown_part']
        expect(daily_log.pain_parts_jp).to eq ['unknown_part']
      end

      it 'start_timeメソッドがdateと同じ値を返すこと（カレンダー表示用）' do
        expect(daily_log.start_time).to eq daily_log.date
      end
    end

    describe 'アソシエーション' do
      it 'ユーザーに紐付いていない場合は無効であること' do
        daily_log.user = nil
        daily_log.valid?
        expect(daily_log.errors[:user]).to be_present
      end
    end
  end
end