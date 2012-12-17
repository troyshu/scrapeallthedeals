include StaticPagesHelper
require 'hpricot'
require 'mechanize'

class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def get_category_scores(text, probability_map)
	#text: a list of words in document

	categories = probability_map.keys()
	category_scores = {}
	categories.each do |category|
		freq_probabilities = probability_map[category] #word->probability (given category)
		sum=0
		test_words.each do |word| #so for each word in the test document
			probability = freq_probabilities[word]
			sum += Math::log(probability)
		end
		category_scores[category]=sum
	end

	return category_scores #the scores that are larger (less negative) are the highest likelihood categories

  end
	
  def calculate_nb_probabilities(text)
	#text: a list of words in document

	#get deal categories/deal_type
	categories = []

	TrainingDeal.select("DISTINCT(deal_type)").each do |type|
		categories.append(type.deal_type)
	end
	
	nb_probability_map = {}
	#for each category
	categories.each do |category|
		#create a frequency probability map: word->probability
		probability_map = {}
		test_words.each do |word|
			if !probability_map.keys().include? word
				#calculate the frequency probability of current word
				#don't forget to laplace smooth

				#numerator: smoothed frequency of current word given category
				if WordCount.where(:word=>word, :category=>category).count==0
					numerator = 1
				else
					numerator = WordCount.where(:word=>word, :category=>category)[0].count.to_f+1
				end

				#get total frequency of all words given current category
				total_words_given_cat = 0
				all_word_counts = WordCount.where(:category=>category)

				all_word_counts.each do |word_count|
					total_words_given_cat += word_count.count
				end
				#denominator: smoothed frequency of all words given category
				denominator = total_words_given_cat + all_word_counts.count
				denominator = denominator.to_f

				probability = numerator/denominator
				probability_map[word]=probability
			end
		end
		#store this probability map into nb probabilities map
		nb_probability_map[category] = probability_map
	end
	return nb_probability_map
  end



  def delete_bag_of_words
	#delete word counts
	WordCount.delete_all
	#reset all trained flags
	TrainingDeal.where(:trained => true).each do |training_deal|
		training_deal.update_attributes(:trained => false)
	end
  end

  def populate_bag_of_words
  	agent = Mechanize.new

	#loop through all UNTRAINED deals in TrainingDeals
	#for each deal, go to the url
	TrainingDeal.where(:trained => false).each do |training_deal|
		
		#timing purposes
		t = Time.now

		#get current category
		deal_category = training_deal.deal_type
		#get url
		deal_url = training_deal.url
		#scrape description of deal
		begin
			page = agent.get(deal_url)
			response = page.content
			doc = Hpricot(response)
		rescue => ex
			logger.debug("ERROR while scraping url for word counts: #{ex.message}")
			next
		end

		desc=(doc/"/html/body/div/div[@class='row']/div[@class^='span12']/div/div[@class='deal-wrapper']/div/div/div[@id^='view']/p")

		full_description = ""

		desc.each do |desc_subsection|
			full_description += desc_subsection.inner_text
		end

		#clean description
		#remove \n, \r, bullets (•)
		full_description.squish!()
		#full_description.tr!('•','') #character not allowed...
			
		#tokenize words, (also, at the same time remove all punctuation)
		words = full_description.downcase.gsub(' ','_').gsub(/\W/,'').gsub('_',' ').split(' ')

		#aggregate word counts
		word_freq = getWordFrequencyDict(words)

		#for each word count in current description
		training_deal.update_attributes(:trained => true)

		word_freq.keys().each do |word|
			#check bag of words/word count database for existing key [word, category]
			word_count_row = WordCount.where(:category => deal_category, :word => word).first
			#if the key doesn't exist, add it to the database
			if word_count_row == nil
				WordCount.create(:word => word, :category => deal_category, :count => word_freq[word])
			#if the key already exists, add(arithmetic) it to the entry that already exists
			else
				word_count_row.update_attributes(:count => (word_count_row.count+word_freq[word]))
			end
		end

		logger.debug("TrainingDeal id #{training_deal.id} words counted in #{(Time.now-t)} seconds")
	end
  end	
  
  def scrape
		


	  	#xpath for a living social deal:
	  	#/html/body[@class='external www external-www cities cities-show full-width']/div[@class='container main-content']/div[@class='row']/div[@class='span12 content']/div[@id='cities-content-id']/ul[@class='unstyled cities-items']/li[@class='ls-item deal']

		#MIAMI
	  	static_location = "miami"

	  	#LIVINGSOCIAL

		agent = Mechanize.new
		page = agent.get('http://www.livingsocial.com/cities/43-miami')
		response = page.content
		doc = Hpricot(response)
		#deals=(doc/"/html/body[@class='external www external-www cities cities-show full-width']/div[@class='container main-content']/div[@class='row']/div[@class='span12 content']/div[@id='cities-content-id']/ul[@class='unstyled cities-items']/li[@class^='ls-item deal ']") #los angeles
		deals=(doc/"/html/body[@class='external www external-www cities cities-show full-width']/div[@class='container main-content']/div[@class='row']/div[@class='span12 content']/div/ul[@class='unstyled cities-items']/li[@class^='ls-item deal ']") #miami
		@dealsArray = []
		deals.each do |deal|
			name = (deal/"/div[@class='bd']/h1")[0].innerHTML
			headline = (deal/"/div[@class='bd']/h2")[0].innerHTML
			price = parsePrice((deal/"/div[@class='bd']/p[@class='meta']/span[@class='price']")[0].innerHTML)
			location = parseLocation((deal/"/div[@class='hd']/div[@class='meta']/span[@class='deal-location']")[0].innerHTML)
			site="livingsocial"
			picture = deal.at("/div[@class='hd']/img")['src']
			url = "http://www.#{site}.com/#{deal.at("/a")['href']}"
			#deal_type = "adventure"
			external_id = deal['dealid']

			#logger.debug("name: #{name}")
			#logger.debug("headline: #{headline}")
			#logger.debug("price: #{price}")
			#logger.debug("location: #{location}")
			#logger.debug("site: #{site}");
			#logger.debug("picture: #{picture}")
			#logger.debug("url: #{url}")
			#logger.debug("external_id: #{external_id}")

			deal = Deal.new do |d| 
				d.name = name
				d.headline = headline
				d.price = price
				d.location = location
				d.site = site
				d.picture = picture
				d.url = url
				#d.deal_type = deal_type
				d.external_id = external_id
				d.static_location = static_location
			end
			#deal.save
			#logger.debug("saved Deal #{deal.id}")

			#save deal in temporary array
			@dealsArray.push(deal)
		end
		

		#if it's a GET request (i.e. we just want to see what deals we scrape), do the Naive Bayes prediction
		if request.get?
			#for each deal
			@dealsArray.each do |deal|
				deal_url = deal.url
				begin
					page = agent.get(deal_url)
					response = page.content
					doc = Hpricot(response)
				rescue => ex
					logger.debug("ERROR while scraping url for description in category prediction: #{ex.message}")
					next
				end

				desc=(doc/"/html/body/div/div[@class='row']/div[@class^='span12']/div/div[@class='deal-wrapper']/div/div/div[@id^='view']/p")

				full_description = ""

				desc.each do |desc_subsection|
					full_description += desc_subsection.inner_text
				end

				#clean description
				#remove \n, \r, bullets (•)
				full_description.squish!()
				#full_description.tr!('•','') #character not allowed...
					
				#tokenize words, (also, at the same time remove all punctuation)
				words = full_description.downcase.gsub(' ','_').gsub(/\W/,'').gsub('_',' ').split(' ')

				#calculate frequency probabilities, then get most likely categories
				nb_probabilities = calculate_nb_probabilities(words)
				category_scores = get_category_scores(words,nb_probabilities)
				

				#find most likely category
				most_likely_category = nil
				max_score = -9999
				category_scores.keys().each do |category|
					if category_scores[category] > max_score
						max_score=category_scores[category]
						most_likely_category = category
					end
				end

				deal.predicted_deal_type = category

			end
		end


		#POST request (update button click): save selected deals
		if request.post?

			#first, delete all old
			Deal.delete_all

			#logger.debug("post. params #{params}")
			#loop through deals, checking to see if adventure checkbox is checked
			#TODO: loop thorugh deals, checking to see if predicted adventure checkbox is checked
			@dealsArray.each do |deal|
				if params["#{deal.external_id}_#{deal.site}"]=="1"
					#set deal type to adventure
					deal.deal_type="adventure"
					#save deal in database
					deal.save
				end
			end
			
			#THEN, save all deals do the training deals table
			@dealsArray.each do |deal|
				#first, only add deal to training deal if it isn't already in the trainingdeal table
				if TrainingDeal.find_by_deal_id(deal.external_id)==nil
					training_deal = TrainingDeal.new do |d| 
						d.deal_id = deal.external_id
						d.deal_headline = deal.headline
						d.deal_type = deal.deal_type
						d.url = deal.url
						d.trained = false
					end
					training_deal.save
				end
			end

		end

	end

	

end
