class CreateMedicationLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :medication_logs do |t|
      t.references :daily_log, null: false, foreign_key: true
      t.string :medicine_name
      t.string :dosage
      t.boolean :is_taken

      t.timestamps
    end
  end
end
