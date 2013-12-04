class SkuController < ApplicationController
	
	def csv
		respond_to do |format|        
		  format.csv { render layout: false }
		end
	end

end