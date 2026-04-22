class DailyLogsController < ApplicationController
  before_action :authenticate_user!

  def new
    @daily_log = current_user.daily_logs.build(date: params[:date] || Date.today)
    @daily_log.temperature_logs.build 

    current_user.latest_prescribed_medicines.each do |medicine|
      @daily_log.medication_logs.build(
        medicine_name: medicine.name,
        dosage: medicine.dosage,
        is_taken: false
      )
    end

    @daily_log.medication_logs.build if @daily_log.medication_logs.empty?
  end

  def index
    @daily_logs = current_user.daily_logs.includes(:temperature_logs, :medication_logs).order(date: :desc)

    @period = params[:period] || "1month"
    start_date = case @period
                 when "1month"  then 1.month.ago.to_date
                 when "3months" then 3.months.ago.to_date
                 when "6months" then 6.months.ago.to_date 
                 when "1year"   then 1.year.ago.to_date
                 else 1.month.ago.to_date
                 end

    chart_logs = current_user.daily_logs.where(date: start_date..Date.today).order(:date)

    @pain_data = chart_logs.pluck(:date, :pain_vas).to_h
    @fatigue_data = chart_logs.pluck(:date, :fatigue_vas).to_h
    @temp_data = chart_logs.joins(:temperature_logs).group(:date).maximum(:value)

    respond_to do |format|
      format.html
      format.csv do
        send_data @daily_logs.to_csv, filename: "my_health_log_#{Date.today}.csv"
      end
      format.pdf do
        render pdf: "health_report_#{Date.today}",
               layout: 'pdf',
               template: 'daily_logs/report',
               formats: [:html],
               encoding: 'UTF-8',
               show_as_html: params[:debug].present?
      end
    end
  end

  def show
    @daily_log = current_user.daily_logs.find(params[:id])
  end

  def edit
    @daily_log = current_user.daily_logs.find(params[:id])
  end

  def create
    @daily_log = current_user.daily_logs.build(daily_log_params)
    if @daily_log.save
      redirect_to daily_logs_path(@daily_log), notice: "体調を記録しました！"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @daily_log = current_user.daily_logs.find(params[:id])
    if @daily_log.update(daily_log_params)
      redirect_to daily_log_path(@daily_log), notice: "体調ログを更新しました。"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def analysis
    # 1. 期間の設定
    @start_date = params[:start_date].presence || 30.days.ago.to_date.to_s
    @end_date = params[:end_date].presence || Date.today.to_s

    # 2. データの取得
    @logs = current_user.daily_logs
                        .includes(:temperature_logs, :medication_logs)
                        .where(date: @start_date..@end_date)
                        .order(:date)

    # 3. グラフ用データの作成
    @pain_vas_data = @logs.map { |log| [log.date, log.pain_vas] }
    @fatigue_vas_data = @logs.map { |log| [log.date, log.fatigue_vas] }
    @temperature_data = @logs.map { |log| [log.date, log.temperature_logs.maximum(:value) || 0] }

    # 4. ヒートマップ用データの集計
    @pain_counts = Hash.new(0)
    @logs.each do |log|
      parts = log.pain_parts
      
      # ✅ 安全な解析処理
      if parts.is_a?(String) && parts.present?
        begin
          decoded_parts = JSON.parse(parts)
          decoded_parts&.each { |part| @pain_counts[part] += 1 }
        rescue JSON::ParserError
          # データが不正な場合はスキップ
        end
      elsif parts.is_a?(Array)
        parts.each { |part| @pain_counts[part] += 1 }
      end
    end

    @has_pain_data = @pain_counts.any?
    @max_count = @has_pain_data ? @pain_counts.values.max : 1

    # 5. 出力形式ごとの処理
    respond_to do |format|
      format.html
      
      # ✅ ここを修正：テンプレートを探さず、モデルの to_csv メソッドなどを直接呼び出す
      format.csv do
        # もし DailyLog モデルに self.to_csv(logs) を定義している場合
        send_data @logs.to_csv, 
                  filename: "health_log_#{@start_date}_to_#{@end_date}.csv", 
                  type: :csv
      end

      format.pdf do
        @daily_logs = @logs.reverse_order 
        render pdf: "summary_report_#{@start_date}",
               layout: 'pdf',
               template: 'daily_logs/report',
               formats: [:html],
               encoding: 'UTF-8',
               show_as_html: params[:debug].present?
      end
    end
  end

  private

  def daily_log_params
    params.require(:daily_log).permit(
      :date, :condition, :stiffness_duration, :pain_vas, :fatigue_vas, :memo,
      :pain_parts, { pain_parts: [] },
      temperature_logs_attributes: [:id, :value, :measured_at, :_destroy],
      medication_logs_attributes: [:id, :medicine_name, :dosage, :is_taken, :_destroy]
    )
  end
end