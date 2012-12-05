require 'StaticPagesHelper'

class StaticPagesController < ApplicationController
  def home
  end

  def help
  end


  def scrape
  	#xpath for a living social deal:
  	#/html/body[@class='external www external-www cities cities-show full-width']/div[@class='container main-content']/div[@class='row']/div[@class='span12 content']/div[@id='cities-content-id']/ul[@class='unstyled cities-items']/li[@class='ls-item deal']

  	#LIVINGSOCIAL
	agent = Mechanize.new
	page = agent.get('http://www.livingsocial.com/cities/4-los-angeles')
	response = page.content
	doc = Hpricot(response)
	deals=(doc/"/html/body[@class='external www external-www cities cities-show full-width']/div[@class='container main-content']/div[@class='row']/div[@class='span12 content']/div[@id='cities-content-id']/ul[@class='unstyled cities-items']/li[@class^='ls-item deal ']")
	deals.each do |deal|
		name = (deal/"/div[@class='bd']/h1")[0].innerHTML
		headline = (deal/"/div[@class='bd']/h2")[0].innerHTML
		price = parsePrice((deal/"/div[@class='bd']/p[@class='meta']/span[@class='price']")[0].innerHTML)
		location = (deal/"/div[@class='hd']/div[@class='meta']/span[@class='deal-location']")[0].innerHTML

	end


  end
end
