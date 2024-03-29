class PlanningController < ApplicationController
  
  def get_parent_bom
    if params[:kode].present?
      @search_bom = JdeBillOfMaterial.params_bom_detail(params[:kode])
      @parent_bom = JdeBillOfMaterial.get_parent_bom(params[:kode], current_user.branch)
    end
  end
  
  def pbjm_analisis
    @bp_prod = BranchProduction.all
    # @unlist_plan = Jde.pbjm_unlisted(params[:start_date]) if params[:start_date].present?
    @pbjm_a = Jde.pbjm_analisis(params[:start_date], params[:to_date]) if params[:start_date].present?
    
    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "analisa_ppc", :filename => "Analisa PPC.xlsx"}
    end
  end
  
  def upload_for_bom
    if params[:file].present?
      @bom = BillOfMaterial.import(params[:file], current_user.branch)
      unless @bom.kind_of?(Array)
        if @bom == "over_limit"
          redirect_to planning_upload_for_bom_url, alert: "BOM Gagal dihitung, total melebihi 300 kode barang"
        elsif (@bom.is_a? Integer)
          redirect_to planning_upload_for_bom_url, alert: "BOM Gagal dihitung, Isi Branch Plan di kolom #{@bom}"
        else
          redirect_to planning_upload_for_bom_url, alert: "BOM Gagal dihitung, kode barang #{@bom} tidak terdaftar"
        end
      end
    end
  end
  
  def import
    BillOfMaterial.import(params[:file], current_user.branch)
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