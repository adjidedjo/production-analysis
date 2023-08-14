class BillOfMaterial < ActiveRecord::Base
  def self.import(file, userbp)
    spreadsheet = Roo::CSV.new(file.path, csv_options: {encoding: Encoding::ISO_8859_1})
    #spreadsheet = Roo::Spreadsheet.open(file.path, { csv_options: { encoding: 'bom|utf-8' } })
    header = spreadsheet.row(1)
    item = []
    if spreadsheet.last_row > 301
      return "over_limit"
    end
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      if row["branch_plan"].nil?
        return i
      end
      short_item = JdeItemMaster.get_short_item(row["item_number"])
      if short_item.nil?
        return row["item_number"]
      end
      item << JdeBillOfMaterial.count_bom_cunsumtion(short_item.imitm.to_i, row["qty"], row["branch_plan"])
    end
    
    sum_items = item.flatten.group_by(&:ixlitm).map{|key, val|
      {:ixlitm => key, :imdsc => val.first.imdsc1.strip+' '+val.first.imdsc2.strip,:ixum => val.first.ixum, :ixmmcu => val.first.ixmmcu,
        :total => val.sum{|v| v.ixqnty.to_f}}}
    return sum_items
  end
end
