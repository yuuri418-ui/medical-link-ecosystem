class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    if current_user
      # カレンダー表示用に今月のログを取得
      @daily_logs = current_user.daily_logs.includes(:temperature_logs)
    else
      @daily_logs = []
    end
  end
end
