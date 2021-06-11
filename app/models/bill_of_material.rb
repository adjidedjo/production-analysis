class BillOfMaterial < ActiveRecord::Base
  def self.import(file, userbp)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    item = []
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      short_item = JdeItemMaster.get_short_item(row["item_number"])
      if short_item.nil?
        return row["item_number"]
      end
      unless userbp == '11003'
        plan = short_item.imprp4.strip == 'KB' ? '2' : '1'
        userbpplan = userbp + plan
      else
        userbpplan = userbp
      end
      item << JdeBillOfMaterial.count_bom_cunsumtion(short_item.imitm.to_i, row["qty"], userbpplan)
    end
    
    sum_items = item.flatten.group_by(&:ixlitm).map{|key, val|
      {:ixlitm => key, :imdsc => val.first.imdsc1.strip+' '+val.first.imdsc2.strip,:ixum => val.first.ixum, :ixmmcu => val.first.ixmmcu,
        :total => val.sum{|v| v.ixqnty.to_f}}}
    return sum_items
  end
end