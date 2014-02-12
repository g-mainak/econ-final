class Delete

  def self.del_all
    a = Sku.limit(80000).where("created_at >= #{Date.yesterday}").group_by {|model| [model.sku_id, model.product_id]}
    a.values.each do |i|
      if i.count == 1
        next
      end
      i.sort_by{ |k| k.created_at}
      #i.each {|j| puts j.created_at}
      f = i.shift
      i.each{|j| j.destroy}
    end
  end
  
end
