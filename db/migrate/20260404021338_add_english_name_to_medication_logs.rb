class AddEnglishNameToMedicationLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :medication_logs, :english_name, :string
  end
end
