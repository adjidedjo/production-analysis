class JdeBillOfMaterial < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "proddta.f3002" #im
  
  def self.count_bom_cunsumtion(item_number, qty)
    find_by_sql("
      SELECT a.ixlitm, a.ixqnty, a.ixum, im.imdsc1, im.imdsc2 FROM 
        (
          SELECT (SUM(IXQNTY)/100.00)*#{qty.to_f} AS ixqnty, MAX(ixlitm) ixlitm, ixum, ixitm 
          FROM PRODDTA.F3002 WHERE ixkit = '#{item_number}' AND ixmmcu LIKE '%11001MT' 
          GROUP BY ixum, ixitm
        ) a
        LEFT JOIN
        (
          SELECT imitm, imdsc1, imdsc2 FROM PRODDTA.F4101
        ) im ON im.imitm = a.ixitm
    ")
  end
end 