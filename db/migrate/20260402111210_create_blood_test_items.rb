class CreateBloodTestItems < ActiveRecord::Migration[7.1]
  def change
    create_table :blood_test_items do |t|
      t.references :visit_log, null: false, foreign_key: true
      t.string :name
      t.float :value
      t.string :unit
      t.string :reference_range
      t.string :category

      t.timestamps
    end
  end
end
