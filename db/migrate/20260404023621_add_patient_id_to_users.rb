class AddPatientIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :patient_id, :string
  end
end
