class DailyLogsController < ApplicationController
  before_action :authenticate_user!

  def new
    @daily_log = current_user.daily_logs.build
    @daily_log.temperature_logs.build 

    current_user.latest_prescribed_medicines.each do |medicine|
      @daily_log.medication_logs.build(
        medicine_name: medicine.name,
        dosage: medicine.dosage,
        is_taken: false # 初期値は未服用
      )
    end

    # もし処方薬が一つも登録されていない場合のために、空の入力欄も一つ作っておく
    @daily_log.medication_logs.build if @daily_log.medication_logs.empty?
  end

  def index
    @daily_logs = current_user.daily_logs.includes(:temperature_logs).order(date: :desc)

    # 1. 表示期間の判定（デフォルトは1ヶ月）
    @period = params[:period] || "1month"
    start_date = case @period
                 when "1month"  then 1.month.ago.to_date
                 when "3months" then 3.months.ago.to_date
                 when "6months" then 6.months.ago.to_date 
                 when "1year"   then 1.year.ago.to_date
                 else 1.month.ago.to_date
                 end

    # 2. データの取得
    chart_logs = current_user.daily_logs.where(date: start_date..Date.today).order(:date)

    # 3. 各グラフ用データの作成
    @pain_data = chart_logs.pluck(:date, :pain_vas).to_h
    @fatigue_data = chart_logs.pluck(:date, :fatigue_vas).to_h
  
    # 体温は1日に複数ある可能性があるため、その日の「最高体温」をグラフにする例
    @temp_data = chart_logs.joins(:temperature_logs)
                           .group(:date)
                           .maximum(:value)
  end

  def show
    @daily_log = current_user.daily_logs.find(params[:id])
  end

  def edit
    @daily_log = current_user.daily_logs.find(params[:id])
    # 編集画面でも、もし体温や服薬のデータがなければ箱を作っておく（必要に応じて）
  end

  def create
    @daily_log = current_user.daily_logs.build(daily_log_params)
    if @daily_log.save
      redirect_to root_path, notice: "体調を記録しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @daily_log = current_user.daily_logs.find(params[:id])
    if @daily_log.update(daily_log_params)
      redirect_to daily_log_path(@daily_log), notice: "体調ログを更新しました。"
    else
      render :edit, status: :unprocessable_entity
   end
  end

  def analysis
    @start_date = params[:start_date].presence || 30.days.ago.to_date.to_s
    @end_date = params[:end_date].presence || Date.today.to_s

    @logs = current_user.daily_logs.where(date: @start_date..@end_date)

    # --- 3. グラフ用データの作成 ---
    @pain_vas_data = @logs.map { |log| [log.date, log.pain_vas] }
    @fatigue_vas_data = @logs.map { |log| [log.date, log.fatigue_vas] }

    @temperature_data = @logs.map { |log| [log.date, log.temperature] }
  
    @pain_counts = Hash.new(0)
  
    @logs.each do |log|
      # pain_partsを安全に読み込む
      parts = log.pain_parts
      parts = JSON.parse(parts) if parts.is_a?(String)
    
      parts&.each { |part| @pain_counts[part] += 1 }
    end

    # 集計した結果、一つでも部位が選ばれていれば true
    @has_pain_data = @pain_counts.any?

    if @has_pain_data
      @max_count = @pain_counts.values.max
    else
      @max_count = 1
    end
  end

  private

  def daily_log_params
    params.require(:daily_log).permit(
      :date, :condition, :stiffness_duration, :pain_vas, :fatigue_vas, :memo,
      temperature_logs_attributes: [:id, :value, :measured_at, :_destroy], # ここはカンマ
      medication_logs_attributes: [:id, :medicine_name, :dosage, :is_taken, :_destroy] # ここが最後なので閉じカッコ
    )
  end
end
