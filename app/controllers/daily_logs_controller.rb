class DailyLogsController < ApplicationController
  before_action :authenticate_user!

  def new
    @daily_log = current_user.daily_logs.build
    # 体温の入力欄を1つ用意しておく（複数入力も可能）
    @daily_log.temperature_logs.build 
    @daily_log.medication_logs.build
  end

  def index
    # 新しい日付順に取得
    @daily_logs = current_user.daily_logs.includes(:temperature_logs).order(date: :desc)
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
    params.require(:daily_log).permit(:date, :condition, :stiffness_duration, :pain_vas, :fatigue_vas, :memo,
    temperature_logs_attributes: [:id, :value, :measured_at, :_destroy]), 
    medication_logs_attributes: [:id, :medicine_name, :dosage, :is_taken, :_destroy]
  end
end
