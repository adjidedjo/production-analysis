class BillOfMaterial < ActiveRecord::Base
  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    item = []
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      short_item = JdeItemMaster.get_short_item(row["item_number"])
      item << JdeBillOfMaterial.count_bom_cunsumtion(short_item.imitm.to_i, row["qty"])
    end
    
    sum_items = item.flatten.group_by(&:ixlitm).map{|key, val|
      {:ixlitm => key, :imdsc => val.first.imdsc1,:ixum => val.first.ixum, :total => val.sum{|v| v.ixqnty.to_f}}}
    return sum_items
  end
end