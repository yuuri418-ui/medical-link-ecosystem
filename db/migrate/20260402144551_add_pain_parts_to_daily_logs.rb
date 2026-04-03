class AddPainPartsToDailyLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :daily_logs, :pain_parts, :json
  end
end
