require 'csv'
class Sku < ActiveRecord::Base

	@api_key = "697a640f5ac86b35fa3c41e2cce2678d"

	def self.get_active
		uri = "https://api.gilt.com/v1/sales/active.json?apikey=#{@api_key}"
		encoded_uri = URI::encode(uri)
		response = HTTParty.get(encoded_uri)
		json_response = JSON.parse(response.body)
		created=0
		json_response["sales"].each do |sale|
		  sale_name = sale["name"]
		  begin_time = Time.iso8601(sale["begins"])
		  end_time = Time.iso8601(sale["ends"])
		  interval = (end_time - begin_time)/(60*60)
		  if ((Time.now - begin_time < 1.hour) && (sale["products"]))
		    sale["products"].each do |product_url|
		      product = HTTParty.get(product_url + "?apikey=#{@api_key}")
		      product_json = JSON.parse(product.body)
		      product_json["skus"].each do |sku|
		      	Sku.create(
		      				sale_name: sale_name,
		              begin_time: begin_time,
		              end_time: end_time,
		              interval: interval.to_s,
		              product_name: product_json["name"],
		              product_brand: product_json["brand"],
		              product_content: product_json["content"].to_s,
		              initial_count: sku["units_for_sale"],
		              msrp: sku["msrp_price"],
		              sale: sku["sale_price"],
		              sku_attributes: sku["attributes"].to_s,
		              sale_id: sale["sale_key"],
		              product_id: product_json["id"],
		              sku_id: sku["id"])
		      	created+=1
		      end
		    end
		  end
		end
		puts "Created #{created} SKUs"
	end

	def self.get_ended
		just_ended = Sku.where(end_time: Time.now..(Time.now + 30.minutes)).group_by(&:product_id)
		ended=0
		just_ended.each do |id, product_group|
			uri = "https://api.gilt.com/v1/products/#{id}/detail.json?apikey=#{@api_key}"
			response = HTTParty.get(uri)
			json_response = JSON.parse(response.body)
			if json_response["skus"]
				json_response["skus"].each do |sku|
					sku_to_be_updated = Sku.find_by(sku_id: sku["id"])
					sku_to_be_updated.final_count = sku["units_for_sale"]
					sku_to_be_updated.save!
					ended+=1
				end
			else
				puts "No reponse: " + json_response['id'].to_s
			end
		end
		puts "Ended #{ended} SKUs"
	end

	def self.print_ended
		file_name = "csv/#{Date.yesterday.to_s(:db)}.csv"
		just_ended = Sku.where(end_time: (Time.now - 1.day)..(Time.now))
		CSV.open(file_name, "wb") do |csv|
		  csv << Sku.attribute_names.map{ |i| i.humanize}
		  just_ended.each do |sku|
		    csv << sku.attributes.values
		  end
		end
	end

	def self.get_upcoming
		uri = "https://api.gilt.com/v1/sales/upcoming.json?apikey=#{@api_key}"
                encoded_uri = URI::encode(uri)
                response = HTTParty.get(encoded_uri)
                json_response = JSON.parse(response.body)
		upcoming_sale_time = json_response["sales"].map{|i| Time.iso8601 i["begins"]}
		puts upcoming_sale_time.uniq.sort
	end

	def self.get_ending
		Sku.all.map{|i| i.end_time }.uniq.sort
	end
end
