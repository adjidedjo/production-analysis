class JdeBillOfMaterial < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "proddta.f3002" #im
  
  def self.params_bom_detail(kode)
    short_item = JdeItemMaster.get_short_item(kode)
    find_by_sql("
      select  DISTINCT(bom.IXITM), im.imlitm, im.imdsc1, im.imdsc2
        from  PRODDTA.F3002 bom LEFT JOIN PRODDTA.F4101 im ON bom.IXITM = im.IMITM 
        where bom.IXITM = '#{short_item.imitm.to_i}' and im.imseg4 != 'K'
    ")
  end
  
  def self.get_parent_bom(kode, bp)
    short_item = JdeItemMaster.get_short_item(kode)
    find_by_sql("
      with recursion_view( BASE, IXKIT, IXITM ) as (
      select  IXKIT BASE, IXKIT, IXITM      -- ANCHOR leg of recursive query
        from  PRODDTA.F3002 
        where IXITM = '#{short_item.imitm.to_i}' AND IXMMCU LIKE '%#{bp}%'
      
      union all
      
      select f.BASE, e.IXKIT, e.IXITM  -- RECURSIVE leg of recursive query
        from  PRODDTA.F3002 e, recursion_view f 
        where e.IXITM = f.IXKIT
      )
      select r.BASE, IXKIT, IM.IMLITM, IM.IMDSC1, IM.IMDSC2
      from  recursion_view r
      LEFT JOIN PRODDTA.F4101 im
            ON r.IXKIT = im.imitm
            WHERE im.imtmpl = 'BJ MATRASS' and im.imseg4 != 'K'
            order by 
              r.IXKIT, r.IXITM
    ")
  end
  
  def self.count_bom_cunsumtion(item_number, qty, userbp)
    find_by_sql("
        with recursion_view(BASE, IXKIT, IXLITM, IXITM, IXQNTY, IXMMCU, IXUM) as (
         -- first step, get rows to start with
         select 
           IXKIT BASE, IXKIT, IXLITM, IXITM, 
           (IXQNTY/100.00)*#{qty}, IXMMCU, IXUM
        from 
          PRODDTA.F3002
        WHERE IXKIT = '#{item_number}' AND IXMMCU LIKE '%#{userbp}%'
          
        
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
          AND current_level.IXMMCU LIKE '%#{userbp}%'
          AND current_level.IXFTRP > 0
          AND current_level.IXEFFT >= '#{date_to_julian(Date.today)}'
          AND current_level.IXFVBT = 'V'
          AND current_level.IXFTRC = 'N'
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

  def self.date_to_julian(date)
    date = date.to_date
    1000*(date.year-1900)+date.yday
  end
  
  def self.julian_to_date(jd_date)
    if jd_date.nil? || jd_date == 0
      0
    else
      Date.parse((jd_date+1900000).to_s, 'YYYYYDDD')
    end
  end
end 