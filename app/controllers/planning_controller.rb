class PlanningController < ApplicationController
  
  def outstanding_order
    @out_daily = OutstandingProduction.all
  end
end