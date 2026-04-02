class CreateBloodTestResults < ActiveRecord::Migration[7.1]
  def change
    create_table :blood_test_results do |t|
      t.references :visit_log, null: false, foreign_key: true
      t.string :item_name
      t.float :value
      t.string :unit

      t.timestamps
    end
  end
end
