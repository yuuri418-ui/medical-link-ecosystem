class VisitLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @visit_logs = current_user.visit_logs.order(visited_on: :desc)
  end

  def new
    @visit_log = current_user.visit_logs.build
    # 最初から3つずつ入力欄を表示させる
    3.times { @visit_log.blood_test_results.build }
    3.times { @visit_log.prescribed_medicines.build }
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
  end

  private

  def visit_log_params
    params.require(:visit_log).permit(
      :visited_on, :hospital_name, :department, :doctor_name, :memo,
      blood_test_results_attributes: [:id, :item_name, :value, :unit, :_destroy],
      prescribed_medicines_attributes: [:id, :name, :dosage, :_destroy]
    )
  end
end
