include StaticPagesHelper
require 'hpricot'
require 'mechanize'

class StaticPagesController < ApplicationController

  
  before_filter :signed_in_user, only: [:scrape, :view_scraped, :populate_bag_of_words, :delete_bag_of_words]

  def home
  end

  def help
  end

  def self.get_category_scores(text, probability_map)
	#text: a list of words in document
	test_words = text

	categories = probability_map.keys()
	category_scores = {}

	priors = {}
	categories.each do |category|
		priors[category] = TrainingDeal.where(:deal_type=>category, :trained=>true).count.to_f/TrainingDeal.count.to_f
	end

	categories.each do |category|
		freq_probabilities = probability_map[category] #word->probability (given category)
		sum=0
		test_words.each do |word| #so for each word in the test document
			probability = freq_probabilities[word]
			sum += Math::log(probability)
		end

		
		sum+=Math::log(priors[category])

		category_scores[category]=sum
	end

	return category_scores #the scores that are larger (less negative) are the highest likelihood categories

  end
	
  def self.calculate_nb_probabilities(text)
	#text: a list of words in document
	test_words = text

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

  def self.populate_bag_of_words_helper
	
  	agent = Mechanize.new



	#naive bayes COMPLEMENT logic
	#get categories
	#get deal categories/deal_type
	categories = []

	TrainingDeal.select("DISTINCT(deal_type)").each do |type|
		categories.append(type.deal_type)
	end

	#find size of smallest category (ONLY count untrained deals)
	smallest_size = 999
	smallest_category = nil
	categories.each do |category|
		current_size = TrainingDeal.where(:deal_type => category, :trained=>false).count
		if current_size < smallest_size
			smallest_size=current_size
			smallest_category = category
		end
	end

	#smallest size multipler: we may not want the categories to be exactly equal...
	size_multiplier = 1
	smallest_size *= size_multiplier

	logger.debug("smallest category is #{smallest_category} with #{smallest_size} trainingdeals")

	#randomly select trainingdeals such that the number of training deals in each category are the same
	training_deals = []
	categories.each do |category|
		training_deals += TrainingDeal.where(:deal_type => category, :trained=>false).sample(smallest_size)
	end


	#loop through all UNTRAINED deals in TrainingDeals
	#for each deal, go to the url
	#TrainingDeal.where(:trained => false).each do |training_deal|
	training_deals.each do |training_deal|	
		#timing purposes
		t = Time.now

		#get current category
		deal_category = training_deal.deal_type


		#TRAINING ON HEADLINE get headline and title

		deal_headline = training_deal.deal_headline


		#clean headline
		#remove \n, \r, bullets (•)
		deal_headline.squish!()
			
		#tokenize words, (also, at the same time remove all punctuation)
		words = deal_headline.downcase.gsub(' ','_').gsub(/\W/,'').gsub('_',' ').split(' ')


=begin
		#TRAINING ON DEAL DESCRIPTION
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
=end


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

  def populate_bag_of_words

	StaticPagesController.delay.populate_bag_of_words_helper()

  end

  def self.scrape_helper(params)
	
		if params[:static_location]
			static_location = params[:static_location]
		else
			#default MIAMI
	  		static_location = "miami"
		end

		#first delete old just_scraped deals for location
		Deal.where(:static_location=>static_location, :just_scraped=>true).delete_all

	  	#xpath for a living social deal:
	  	#/html/body[@class='external www external-www cities cities-show full-width']/div[@class='container main-content']/div[@class='row']/div[@class='span12 content']/div[@id='cities-content-id']/ul[@class='unstyled cities-items']/li[@class='ls-item deal']

		#look up url from our database
		url_suffix = LocationUrlMap.where(:static_location=>static_location, :site=>"livingsocial")[0].suffix
		url = "http://www.livingsocial.com/cities/#{url_suffix}"

	  	#LIVINGSOCIAL

		agent = Mechanize.new
		page = agent.get(url) 
		response = page.content
		doc = Hpricot(response)
		#deals=(doc/"/html/body[@class='external www external-www cities cities-show full-width']/div[@class='container main-content']/div[@class='row']/div[@class='span12 content']/div[@id='cities-content-id']/ul[@class='unstyled cities-items']/li[@class^='ls-item deal ']") #los angeles
		deals=(doc/"/html/body[@class='external www external-www cities cities-show full-width']/div[@class='container main-content']/div[@class='row']/div[@class='span12 content']/div/ul[@class='unstyled cities-items']/li[@class^='ls-item deal ']") #miami. should be same for other locations...
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
			
			if location=="national" #skip national deals
				next
			end
			
			adeal = Deal.new do |d| 
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
				d.just_scraped = true

			end
			#deal.save
			#logger.debug("saved Deal #{deal.id}")

			#save deal in temporary array
			@dealsArray.push(adeal)
		end
		

		#do the Naive Bayes PREDICTION

		if WordCount.all.count > 0
			#for each deal
			@dealsArray.each do |deal|


				#alternative implementation: use deal HEADLINE

				deal_headline = deal.headline

				#clean headline
				deal_headline.squish!()
				words = deal_headline.downcase.gsub(' ','_').gsub(/\W/,'').gsub('_',' ').split(' ')


				#get the deal url (to get the deal DESCRIPTION)
=begin
				deal_url = deal.url
				begin
					page = agent.get(deal_url)
					response = page.content
					doc = Hpricot(response)
				rescue => ex
					logger.debug("ERROR while scraping url for description in category prediction: #{ex.message}")
					next
				end

				#then get the deal description
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
=end



				#calculate frequency probabilities, then get most likely categories
				nb_probabilities = StaticPagesController.calculate_nb_probabilities(words)
				category_scores = StaticPagesController.get_category_scores(words,nb_probabilities)
				
				logger.debug("category scores: #{category_scores}")

				#find most likely category
				most_likely_category = nil
				max_score = -9999
				category_scores.keys().each do |category|
					if category_scores[category] > max_score
						max_score=category_scores[category]
						most_likely_category = category
					end
				end

				#find second most likely category, so that we can calculate the difference in scores b/w the most and second most likely
				category_scores.delete(most_likely_category) #delete the most likely category
				secod_most_likely_category = nil
				second_max_score = -9999
				category_scores.keys().each do |category|
					if category_scores[category] > second_max_score
						second_max_score=category_scores[category]
						second_most_likely_category = category
					end
				end

				score_diff = (max_score-second_max_score)
				score_diff = (score_diff / second_max_score.abs)*100

				deal.predicted_deal_type = most_likely_category
				deal.nb_diff = score_diff
			end
		else #if we have no training data, just set nb_diff to zero for all deals, so we can still display them
			@dealsArray.each do |deal|
				deal.nb_diff = 0
			end
		end

		#save all dealsArray to table (remember, they are tagged with just_scraped=true)
		@dealsArray.each do |deal|
			logger.debug("saving scraped deal #{deal.id}")
			deal.save
		end


  end

  def scrape


	StaticPagesController.delay.scrape_helper(params)
	@static_location = params[:static_location]
  end

  def view_scraped


  	static_location = params[:static_location]
  	@dealsArray = []
	Deal.where(:just_scraped=>true, :static_location=>static_location).each do |deal|
		@dealsArray.push(deal)
	end

	if request.post? #we hit the submit button
		#first, delete all old
		Deal.where(:static_location=>static_location).delete_all

		#logger.debug("post. params #{params}")
		#loop through deals, checking to see if adventure checkbox is checked
		#!!!TODO: loop thorugh deals, checking to see if predicted adventure checkbox is checked. or some other way to get the predicted category type, without doing the whole naive bayes prediction again...
		anotherArray = []

		@dealsArray.each do |deal|
			if params["#{deal.external_id}_#{deal.site}"]=="1"
				newdeal = deal.dup
				#set deal type to adventure
				newdeal.deal_type="adventure"
				newdeal.just_scraped=false
				#save deal in database
				newdeal.save
				#add to temp array
				anotherArray.push(newdeal)
			else
				anotherArray.push(deal)
			end
		end
		
		@dealsArray = anotherArray.dup

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
			else
				logger.debug("deal with external id #{deal.external_id} already exsits")
			end
		end
	end

  

  end

  private

	  def signed_in_user
	      unless signed_in?
	        redirect_to root_url
	      end
	  end
  

end
