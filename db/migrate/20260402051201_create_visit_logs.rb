class CreateVisitLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :visit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.date :visited_on
      t.string :hospital_name
      t.string :department
      t.string :doctor_name
      t.text :memo

      t.timestamps
    end
  end
end
