class PlanningController < ApplicationController
  
  def upload_for_bom
    if params[:file].present?
      @bom = BillOfMaterial.import(params[:file])
    end
  end
  
  def import
    BillOfMaterial.import(params[:file])
    redirect_to planning_upload_for_bom_url, notice: 'BOM Has Been Calculated.'
  end
  
  def outstanding_order
    @out_daily = OutstandingProduction.get_outstanding
  end
  
  def aging_orders
    @age_daily = OutstandingProduction.aging_order_calculation(current_user)
  end
end