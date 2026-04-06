class ChangeAddressColumnInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :address, true
  end
end
