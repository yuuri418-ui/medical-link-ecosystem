require 'rails_helper'

RSpec.describe VisitLog, type: :model do
  describe '受診記録のバリデーションテスト' do
    let(:visit_log) { build(:visit_log) }

    context '全ての項目が正しく入力されている場合' do
      it '有効であること' do
        expect(visit_log).to be_valid
      end
    end

    describe '必須項目のバリデーション' do
      it '受診日(visited_on)がない場合は無効であること' do
        visit_log.visited_on = nil
        visit_log.valid?
        expect(visit_log.errors.added?(:visited_on, :blank)).to be_truthy
      end

      it '病院名(hospital_name)がない場合は無効であること' do
        visit_log.hospital_name = nil
        visit_log.valid?
        expect(visit_log.errors.added?(:hospital_name, :blank)).to be_truthy
      end

      it '診療科(department)がない場合は無効であること' do
        visit_log.department = nil
        visit_log.valid?
        expect(visit_log.errors.added?(:department, :blank)).to be_truthy
      end

      it '医師名(doctor_name)がない場合は無効であること' do
        visit_log.doctor_name = nil
        visit_log.valid?
        expect(visit_log.errors.added?(:doctor_name, :blank)).to be_truthy
      end
    end

    describe '文字数・形式の制限' do
      it '病院名が100文字を超える場合は無効であること' do
        visit_log.hospital_name = "あ" * 101
        visit_log.valid?
        # 文字数制限(too_long)のエラーが含まれているか確認
        expect(visit_log.errors.added?(:hospital_name, :too_long, count: 100)).to be_truthy
      end

      it '未来の日付（明日）の場合は無効であること' do
        visit_log.visited_on = Date.tomorrow
        visit_log.valid?
        # カスタムバリデーションのエラーメッセージが存在するか確認
        expect(visit_log.errors[:visited_on]).to be_present
      end
    end

    describe 'アソシエーションのテスト' do
      it 'ユーザーに紐付いていない場合は無効であること' do
        visit_log.user = nil
        visit_log.valid?
        # ユーザー(belongs_to)が必須であるエラーが出ているか確認
        expect(visit_log.errors[:user]).to be_present
      end
    end
  end
end