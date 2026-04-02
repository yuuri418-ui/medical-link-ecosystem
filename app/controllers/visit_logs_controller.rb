class VisitLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    # シンプルに「全ての通院記録を日付順（古い順）」で取得
    # includes を使うことで、N+1問題を回避しつつ関連データを効率よく読み込みます
    @visit_logs = VisitLog.includes(:blood_test_items).order(visited_on: :asc)
  
    # 全ての記録の中から、登録されている「検査項目名」をダブりなく抽出（表の縦軸用）
    # pluck(:id) を使うことで、メモリ消費を抑えてIDだけを取り出します
    @item_names = BloodTestItem.where(visit_log_id: @visit_logs.map(&:id))
                               .pluck(:name)
                               .uniq
                               .sort # 項目名を50音順に並べると見やすくなります
                               
    # 📈 グラフ用データ：CRPの推移を例に（後で項目を選択可能にします）
    # 形式: { "2026-01-01" => 0.3, "2026-02-01" => 0.5 }
    @chart_data = BloodTestItem.where(visit_log: @visit_logs, name: "CRP")
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
      # 失敗したら入力画面を再表示（バリデーションエラーなど）
      render :new, status: :unprocessable_entity
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
