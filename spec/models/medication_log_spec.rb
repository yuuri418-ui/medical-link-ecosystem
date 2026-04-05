require 'rails_helper'

RSpec.describe MedicationLog, type: :model do
  # letを一番外側のdescribe直下に置くことで、全てのテストで med_log が使えます
  let(:med_log) { build(:medication_log) }

  describe 'バリデーションのテスト' do
    before do
      # 通常のテスト時はAPI通信を遮断
      allow_any_instance_of(MedicationLog).to receive(:set_english_name).and_return(true)
    end

    it '薬名と服用フラグがあれば有効であること' do
      expect(med_log).to be_valid
    end

    it '薬名が空の場合は無効であること' do
      med_log.medicine_name = nil
      med_log.valid?
      expect(med_log.errors.added?(:medicine_name, :blank)).to be_truthy
    end

    it '服用状況(is_taken)がnilの場合は無効であること' do
      med_log.is_taken = nil
      med_log.valid?
      expect(med_log.errors.added?(:is_taken, :inclusion, value: nil)).to be_truthy
    end

    it '薬名が100文字を超える場合は無効であること' do
      med_log.medicine_name = "あ" * 101
      med_log.valid?
      expect(med_log.errors.added?(:medicine_name, :too_long, count: 100)).to be_truthy
    end

    describe 'アソシエーション' do
      it 'DailyLogに紐付いていない場合は無効であること' do
        med_log.daily_log = nil
        med_log.valid?
        expect(med_log.errors[:daily_log]).to be_present
      end
    end
  end

  describe 'メソッドのテスト' do
    it 'AI翻訳によってenglish_nameが設定されること' do
      # 翻訳メソッドが実行された時に、強制的に値を書き換えるスタブ
      allow_any_instance_of(MedicationLog).to receive(:set_english_name) do |log|
        log.english_name = "Prednisolone"
      end
      
      med_log.save
      expect(med_log.english_name).to eq "Prednisolone"
    end

    it 'CSV出力に正しいヘッダーが含まれていること' do
      csv = MedicationLog.to_csv
      expect(csv).to include "日付", "薬の名前", "英語名(AI)", "服用状況"
    end
  end
end