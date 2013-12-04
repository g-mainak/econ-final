require 'csv'
module SkuHelper

def show
  CSV.generate do |csv| 
    Sku.find(:all).each do |product|
      csv << product.attributes.values
    end
  end
end
end
