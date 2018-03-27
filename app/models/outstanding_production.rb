class OutstandingProduction < ActiveRecord::Base
  
  def self.get_outstanding
    find_by_sql("
      SELECT item_number, description, segment1, brand, branch, order_in, outstanding_order, buffer, stock_f,
      stock_c, onhand FROM outstanding_productions WHERE branch in (11001, 11002) and 
      order_in > 0 and outstanding_order > 0
    ")
  end
  
  def self.aging_order_calculation(branch)
    find_by_sql("
      SELECT order_no, last_status, customer, brand, branch, item_number, description, order_date, quantity,
      short_item, segment1, originator FROM outstanding_orders WHERE branch_desc = '#{branch}' and quantity > 0
    ")
  end
end