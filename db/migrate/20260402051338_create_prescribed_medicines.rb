class CreatePrescribedMedicines < ActiveRecord::Migration[7.1]
  def change
    create_table :prescribed_medicines do |t|
      t.references :visit_log, null: false, foreign_key: true
      t.string :name
      t.string :dosage

      t.timestamps
    end
  end
end
