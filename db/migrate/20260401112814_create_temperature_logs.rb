class CreateTemperatureLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :temperature_logs do |t|
      t.references :daily_log, null: false, foreign_key: true
      t.datetime :measured_at
      t.float :value, null: false # 体温は必須項目

      t.timestamps
    end
  end
end
