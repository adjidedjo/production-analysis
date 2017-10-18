class PlanningController < ApplicationController
  
  def outstanding_order
    @out_daily = OutstandingProduction.get_outstanding
  end
  
  def aging_orders
    @age_daily = OutstandingProduction.aging_order_calculation
  end
end