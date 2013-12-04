class CreateSku < ActiveRecord::Migration
  def change
    create_table :skus do |t|
    	t.string :sale_name
    	t.datetime :begin_time
    	t.datetime :end_time, index: true
    	t.string :interval
    	t.string :product_name
    	t.string :product_brand
    	t.string :product_content
    	t.integer :initial_count
    	t.integer :final_count
    	t.float :msrp
    	t.float :sale
    	t.string :sku_attributes
        t.string :sale_id, index: true
        t.integer :product_id, index: true
        t.integer :sku_id, index: true

        t.timestamps
    end
  end
end