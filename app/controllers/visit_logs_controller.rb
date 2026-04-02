class VisitLogsController < ApplicationController
  def index
  end

  def new
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
