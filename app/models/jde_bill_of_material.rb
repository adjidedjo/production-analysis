class JdeBillOfMaterial < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "proddta.f3002" #im
  
  def self.count_bom_cunsumtion(item_number, qty)
    find_by_sql("
        with recursion_view(BASE, IXKIT, IXLITM, IXITM, IXQNTY, IXMMCU, IXUM) as (
         -- first step, get rows to start with
         select 
           IXKIT BASE, IXKIT, IXLITM, IXITM, 
           (IXQNTY/100.00)*#{qty}, IXMMCU, IXUM
        from 
          PRODDTA.F3002
        WHERE IXKIT = '#{item_number}' AND IXMMCU LIKE '%11001%'
          
        
        union all
        
        -- subsequent steps
        select
          -- retain base value from previous level
          previous_level.BASE,
          -- get information from current level
          current_level.IXKIT,
          current_level.IXLITM,
          current_level.IXITM,
          -- accumulate sum 
          (previous_level.IXQNTY)*(current_level.IXQNTY/100.00),
          current_level.IXMMCU,
          current_level.IXUM
        from
          recursion_view previous_level,
          PRODDTA.F3002  current_level
        where
          current_level.IXKIT = previous_level.IXITM
          AND current_level.IXMMCU LIKE '%11001%'
        
      )
      select 
        rv.BASE, rv.IXKIT, rv.IXLITM, rv.IXITM, rv.IXQNTY, rv.IXMMCU, rv.IXUM, im.IMDSC1, im.IMDSC2
      from 
        recursion_view rv
      LEFT JOIN PRODDTA.F4101 im
      ON rv.IXITM = im.imitm
      order by 
        rv.BASE, rv.IXKIT, rv.IXITM
    ")
  end
end 