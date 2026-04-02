class VisitLogsController < ApplicationController
  def index
  end

  def new
    @visit_log = current_user.visit_logs.build
    # 最初から3つずつ入力欄を表示させる
    3.times { @visit_log.blood_test_results.build }
    3.times { @visit_log.prescribed_medicines.build }
  end

  def show
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
