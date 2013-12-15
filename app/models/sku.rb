require 'csv'
require 'thread'
class Sku < ActiveRecord::Base

	@api_key = "697a640f5ac86b35fa3c41e2cce2678d"

	def self.get_active
		client = HTTPClient.new
		uri = "https://api.gilt.com/v1/sales/active.json?apikey=#{@api_key}"
		encoded_uri = URI::encode(uri)
		response = client.get(encoded_uri)
		json_response = JSON.parse(response.content)
		created=0
		json_response["sales"].each do |sale|
			sale_name = sale["name"]
			begin_time = Time.iso8601(sale["begins"])
			end_time = Time.iso8601(sale["ends"])
			interval = (end_time - begin_time)/(60*60)
			skus = []
			if ((Time.now - begin_time < 5.hour) && (sale["products"]))
				threads = []
				sale["products"].each do |product_url|
					threads << Thread.new do
						product = client.get(product_url + "?apikey=#{@api_key}")
						product_json = JSON.parse(product.content)
						if product_json["skus"]
							product_json["skus"].each do |sku|
								created+=1
								skus << Sku.new(
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
							end
						end
					end
				end
				threads.each(&:join)
				skus.each do |sku|
					begin
						sku.save
					rescue ActiveRecord::RecordNotUnique => e
						puts "duplicate"
					end
				end
			end
		end
		puts "Created #{created} SKUs"
	end

	def self.get_ended
		just_ended = Sku.where(end_time: (Time.now-30.minutes)..(Time.now + 30.minutes)).group_by(&:product_id)
		client = HTTPClient.new
		ended=0
		just_ended.each do |id, product_group|
			uri = "https://api.gilt.com/v1/products/#{id}/detail.json?apikey=#{@api_key}"
			response = client.get(uri)
			json_response = JSON.parse(response.content)
			if json_response["skus"]
				json_response["skus"].each do |sku|
					sku_to_be_updated = Sku.find_by(sku_id: sku["id"])
					sku_to_be_updated.final_count = sku["units_for_sale"]
					sku_to_be_updated.save!
					ended+=1
				end
			else
				puts "No response: " + json_response['id'].to_s + " " + Time.now.hour.to_s + ":" + Time.now.min.to_s
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
		just_ended.delete_all
	end

	def self.get_upcoming
		client = HTTPClient.new
		uri = "https://api.gilt.com/v1/sales/upcoming.json?apikey=#{@api_key}"
		encoded_uri = URI::encode(uri)
		response = client.get(encoded_uri)
		json_response = JSON.parse(response.content)
		upcoming_sale_time = json_response["sales"].map{|i| Time.iso8601 i["begins"]}
		puts upcoming_sale_time.uniq.sort
	end

	def self.get_ending
		Sku.all.map{|i| i.end_time }.uniq.sort
	end
end
