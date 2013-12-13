class AddUniqueToSku < ActiveRecord::Migration
  def change
  	add_index :skus, [:product_id, :sku_id], unique: true 
  end
end
