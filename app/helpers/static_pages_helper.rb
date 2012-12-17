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

	def getWordFrequencyDict(words)
		wordDict = {}
		words.each do |word|
			if wordDict.keys().include? word
				wordDict[word]=wordDict[word]+1
			else
				wordDict[word]=1
			end
		end
		return wordDict
	end
end
