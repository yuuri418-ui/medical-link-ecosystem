class DailyLogsController < ApplicationController
  before_action :authenticate_user!

  def new
    @daily_log = current_user.daily_logs.build
  end

  def index
    # 新しい日付順に取得
    @daily_logs = current_user.daily_logs.order(date: :desc)
  end

  def show
  end

  def edit
  end

  def create
    @daily_log = current_user.daily_logs.build(daily_log_params)
    if @daily_log.save
      redirect_to root_path, notice: "体調を記録しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def daily_log_params
    params.require(:daily_log).permit(:date, :condition, :stiffness_duration, :pain_vas, :fatigue_vas, :memo)
  end
end
