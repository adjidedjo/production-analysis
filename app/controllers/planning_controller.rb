class PlanningController < ApplicationController
  
  def outstanding_order
    @out_daily = OutstandingProduction.get_outstanding
  end
end