include StaticPagesHelper
require 'hpricot'
require 'mechanize'

class StaticPagesController < ApplicationController
  def home
  end

  def help
  end


  def scrape
		#first, delete all deals
		Deal.delete_all


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
		





		#POST request (update button click): save selected deals
		if request.post?
			#logger.debug("post. params #{params}")
			#loop through deals, checking to see if checkbox is checked
			@dealsArray.each do |deal|
				if params["#{deal.external_id}_#{deal.site}"]=="1"
					#set deal type to adventure
					deal.deal_type="adventure"
					#save deal in database
					deal.save
				end
			end

			
		end

	end

	

end
