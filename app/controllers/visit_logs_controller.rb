class VisitLogsController < ApplicationController

  def index
    @visit_logs = current_user.visit_logs.order(:visited_on)
  
    # 全ての受診記録から、存在する検査項目名を重複なく取得
    @item_names = BloodTestItem.where(visit_log: @visit_logs).pluck(:name).uniq
  
    # 表示する項目を決定（クリックされた項目、なければ最初の項目、それもなければ"CRP"）
    @active_item = params[:graph_item] || @item_names.first || "CRP"

    # 📈 グラフ用データ：@active_item に基づいて取得
    @chart_data = BloodTestItem.where(visit_log: @visit_logs, name: @active_item)
                               .joins(:visit_log)
                               .group("visit_logs.visited_on")
                               .average(:value)
  end

  def new
    @visit_log = current_user.visit_logs.build
    # 最初から3つずつ入力欄を表示させる
    3.times { @visit_log.prescribed_medicines.build }
    3.times { @visit_log.blood_test_items.build }
  end

  def create
    @visit_log = current_user.visit_logs.build(visit_log_params)
    if @visit_log.save
      # 保存できたら一覧画面へ
      redirect_to visit_logs_path, notice: "受診記録を保存しました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @visit_log = current_user.visit_logs.find(params[:id])
  end

  def edit
    @visit_log = VisitLog.find(params[:id])
    # 既存のデータ＋新しい空の入力欄を2つ追加
    2.times { @visit_log.blood_test_items.build }
  end

  def update
    @visit_log = current_user.visit_logs.find(params[:id])
    if @visit_log.update(visit_log_params)
      redirect_to @visit_log, notice: "受診記録を更新しました。"
    else
     render :edit, status: :unprocessable_content
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
