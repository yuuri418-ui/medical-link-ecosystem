
class CreateDailyLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_logs do |t|
      # どのユーザーの記録かを紐付け（インデックスを貼り、削除時はログも消す設定）
      t.references :user, null: false, foreign_key: true
      
      # 記録対象日（1日1件にするための制約は後ほどバリデーションでも設定）
      t.date :date, null: false
      
      # 朝のこわばり（分単位）
      t.integer :stiffness_duration, default: 0
      
      # 痛み VAS (0-10)
      t.integer :pain_vas, default: 0
      
      # 倦怠感 VAS (0-10)
      t.integer :fatigue_vas, default: 0

      # 追加：総合的な体調 (1:非常に悪い 〜 5:非常に良い)
      t.integer :condition, default: 3, null: false
      
      # 自由記述メモ
      t.text :memo

      t.timestamps
    end

    # 同じユーザーが同じ日に2回記録できないようにユニーク制約を追加（DBレベルでのガード）
    add_index :daily_logs, [:user_id, :date], unique: true
  end
end