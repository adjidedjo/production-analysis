class PlanningController < ApplicationController
  
  def pbjm_analisis
    @bp_prod = BranchProduction.all
    # @unlist_plan = Jde.pbjm_unlisted(params[:start_date]) if params[:start_date].present?
    @pbjm_a = Jde.pbjm_analisis(params[:start_date]) if params[:start_date].present?
    
    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "analisa_ppc", :filename => "Analisa PPC.xlsx"}
    end
  end
  
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
    @bp_prod = BranchProduction.all
    @age_daily = OutstandingProduction.aging_order_calculation(params[:branch]) if params[:branch].present?
  end
end