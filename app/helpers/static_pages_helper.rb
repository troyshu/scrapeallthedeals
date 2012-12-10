module StaticPagesHelper
	def parsePrice(price_str)
		price_str = price_str.strip
		#use regex to extract price
		price = price_str.match(/\d+\.*\d*/)[0]
		return price.to_f
	end

	def parseLocation(location_str)
		#get rid of whitespace
		return location_str.strip
	end
end
