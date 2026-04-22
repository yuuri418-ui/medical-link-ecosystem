class VisitLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @visit_logs = current_user.visit_logs.order(:visited_on)
  
    # 全ての受診記録から、存在する検査項目名を重複なく取得
    @item_names = BloodTestItem.where(visit_log: @visit_logs).pluck(:name).uniq
  
    # 表示する項目を決定（クリックされた項目、なければ最初の項目、それもなければ"CRP"）
    @active_item = params[:graph_item] || @item_names.first || "CRP"

    # 📈 グラフ用データ
    @chart_data = BloodTestItem.where(visit_log: @visit_logs, name: @active_item)
                               .joins(:visit_log)
                               .group("visit_logs.visited_on")
                               .average(:value)
  end

  def new
    @visit_log = current_user.visit_logs.build
    # 最初から一定数の入力枠を表示
    5.times { @visit_log.blood_test_items.build }
    3.times { @visit_log.prescribed_medicines.build }
  end

  def create
    @visit_log = current_user.visit_logs.build(visit_log_params)
    if @visit_log.save
      redirect_to visit_logs_path, notice: "受診記録を保存しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @visit_log = current_user.visit_logs.find(params[:id])
  end

  def edit
    @visit_log = current_user.visit_logs.find(params[:id])
    # 💡 blood_test_results を blood_test_items に修正
    # 常に合計5枠（検査）と3枠（薬）になるように調整すると使いやすいです
    (5 - @visit_log.blood_test_items.size).times { @visit_log.blood_test_items.build }
    (3 - @visit_log.prescribed_medicines.size).times { @visit_log.prescribed_medicines.build }
  end

  def update
    @visit_log = current_user.visit_logs.find(params[:id])
    if @visit_log.update(visit_log_params)
      redirect_to visit_log_path(@visit_log), notice: "受診記録を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def visit_log_params
    params.require(:visit_log).permit(
      :visited_on, :hospital_name, :department, :doctor_name, :memo,
      prescribed_medicines_attributes: [:id, :name, :dosage, :_destroy],
      blood_test_items_attributes: [:id, :name, :value, :unit, :category, :reference_range, :_destroy]
    )
  end
end